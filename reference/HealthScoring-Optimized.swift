//
// HealthScoring-Optimized.swift
// Cached Network Health Scoring Algorithm
//
// ISSUE: Health score recalculates from scratch on every query
// SOLUTION: Implement memoization and caching between diagnostic runs
//

import Foundation

class OptimizedHealthScoringEngine {
    
    // MARK: - Caching
    
    private var cachedScore: HealthScore?
    private var scoreCalculationTime: Date?
    private let cacheValidityDuration: TimeInterval = 300  // 5 minutes
    private let scoringLock = NSLock()
    
    // MARK: - Problematic Pattern (DO NOT USE)
    
    /// ❌ SLOW: Recalculates score from scratch every time
    func calculateHealthScoreBlocking(
        dnsLatencies: [String: Int],
        dohLatencies: [String: Int],
        traceData: TraceData,
        warpStatus: WARPStatus
    ) -> HealthScore {
        // Recalculates everything (no caching)
        var score = 0.0
        
        // DNS scoring (0-40 points)
        let avgDnsLatency = Double(dnsLatencies.values.reduce(0, +)) / Double(dnsLatencies.count)
        let dnsScore = max(0, 40 - (avgDnsLatency / 1))  // 40 - (latency in ms)
        score += dnsScore
        
        // DoH scoring (0-20 points)
        let avgDohLatency = Double(dohLatencies.values.reduce(0, +)) / Double(dohLatencies.count)
        let dohScore = max(0, 20 - (avgDohLatency / 2))
        score += dohScore
        
        // WARP bonus (0-20 points)
        let warpScore = warpStatus.enabled ? 20.0 : 0.0
        score += warpScore
        
        // Location score (0-20 points) - recalculated unnecessarily
        let locationScore = calculateLocationScore(traceData)
        score += locationScore
        
        return HealthScore(
            score: min(10.0, score / 10),
            components: [:],
            timestamp: Date()
        )
    }
    
    // MARK: - Optimized Pattern with Caching
    
    /// ✅ FAST: Caches results, returns immediately if valid
    func calculateHealthScoreCached(
        dnsLatencies: [String: Int],
        dohLatencies: [String: Int],
        traceData: TraceData,
        warpStatus: WARPStatus
    ) -> HealthScore {
        scoringLock.lock()
        defer { scoringLock.unlock() }
        
        // Check cache validity
        if let cached = cachedScore,
           let calcTime = scoreCalculationTime,
           Date().timeIntervalSince(calcTime) < cacheValidityDuration {
            return cached  // Return cached result immediately
        }
        
        // Calculate and cache
        let score = _calculateScore(
            dnsLatencies: dnsLatencies,
            dohLatencies: dohLatencies,
            traceData: traceData,
            warpStatus: warpStatus
        )
        
        self.cachedScore = score
        self.scoreCalculationTime = Date()
        
        return score
    }
    
    /// ✅ BEST: Async calculation with memoized components
    func calculateHealthScoreAsync(
        dnsLatencies: [String: Int],
        dohLatencies: [String: Int],
        traceData: TraceData,
        warpStatus: WARPStatus
    ) async -> HealthScore {
        // Check cache on main thread first
        scoringLock.lock()
        if let cached = cachedScore,
           let calcTime = scoreCalculationTime,
           Date().timeIntervalSince(calcTime) < cacheValidityDuration {
            scoringLock.unlock()
            return cached
        }
        scoringLock.unlock()
        
        // Calculate on background thread
        let score = await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let calculated = self._calculateScore(
                    dnsLatencies: dnsLatencies,
                    dohLatencies: dohLatencies,
                    traceData: traceData,
                    warpStatus: warpStatus
                )
                continuation.resume(returning: calculated)
            }
        }
        
        // Cache the result
        scoringLock.lock()
        self.cachedScore = score
        self.scoreCalculationTime = Date()
        scoringLock.unlock()
        
        return score
    }
    
    // MARK: - Component Score Caching
    
    /// Memoized DNS score calculation
    private var dnsScoreCache: [String: Double] = [:]
    
    private func calculateDnsScore(latencies: [String: Int]) -> Double {
        // Create cache key from sorted latencies
        let cacheKey = latencies.sorted { $0.key < $1.key }
            .map { "\($0.key):\($0.value)" }
            .joined(separator: ",")
        
        // Return cached if exists
        if let cached = dnsScoreCache[cacheKey] {
            return cached
        }
        
        // Calculate
        let avgLatency = Double(latencies.values.reduce(0, +)) / Double(latencies.count)
        let score = max(0, 40 - (avgLatency / 1))
        
        // Cache result
        dnsScoreCache[cacheKey] = score
        return score
    }
    
    /// Memoized DoH score calculation
    private var dohScoreCache: [String: Double] = [:]
    
    private func calculateDohScore(latencies: [String: Int]) -> Double {
        let cacheKey = latencies.sorted { $0.key < $1.key }
            .map { "\($0.key):\($0.value)" }
            .joined(separator: ",")
        
        if let cached = dohScoreCache[cacheKey] {
            return cached
        }
        
        let avgLatency = Double(latencies.values.reduce(0, +)) / Double(latencies.count)
        let score = max(0, 20 - (avgLatency / 2))
        
        dohScoreCache[cacheKey] = score
        return score
    }
    
    // MARK: - Private Calculation
    
    private func _calculateScore(
        dnsLatencies: [String: Int],
        dohLatencies: [String: Int],
        traceData: TraceData,
        warpStatus: WARPStatus
    ) -> HealthScore {
        var score = 0.0
        var components: [String: Double] = [:]
        
        // DNS scoring (memoized)
        let dnsScore = calculateDnsScore(latencies: dnsLatencies)
        components["dns"] = dnsScore
        score += dnsScore
        
        // DoH scoring (memoized)
        let dohScore = calculateDohScore(latencies: dohLatencies)
        components["doh"] = dohScore
        score += dohScore
        
        // WARP bonus
        let warpScore = warpStatus.enabled ? 20.0 : 0.0
        components["warp"] = warpScore
        score += warpScore
        
        // Location score (cached by PoP)
        let locationScore = calculateLocationScore(traceData)
        components["location"] = locationScore
        score += locationScore
        
        return HealthScore(
            score: min(10.0, score / 10),
            components: components,
            timestamp: Date()
        )
    }
    
    private var locationScoreCache: [String: Double] = [:]
    
    private func calculateLocationScore(_ traceData: TraceData) -> Double {
        let pop = traceData.pop ?? "UNKNOWN"
        
        // Cache by PoP
        if let cached = locationScoreCache[pop] {
            return cached
        }
        
        // Calculate based on PoP proximity
        // (This is an example; adapt to your actual logic)
        let score = 20.0  // Max location score
        locationScoreCache[pop] = score
        return score
    }
    
    // MARK: - Cache Management
    
    func invalidateCache() {
        scoringLock.lock()
        defer { scoringLock.unlock() }
        
        cachedScore = nil
        scoreCalculationTime = nil
        dnsScoreCache.removeAll()
        dohScoreCache.removeAll()
        locationScoreCache.removeAll()
    }
    
    func printCacheStats() {
        scoringLock.lock()
        defer { scoringLock.unlock() }
        
        print("Health Score Cache Statistics:")
        print("  - Full score cached: \(cachedScore != nil)")
        print("  - DNS score cache size: \(dnsScoreCache.count)")
        print("  - DoH score cache size: \(dohScoreCache.count)")
        print("  - Location score cache size: \(locationScoreCache.count)")
    }
}

// MARK: - Data Models

struct HealthScore: Codable {
    let score: Double  // 0-10
    let components: [String: Double]
    let timestamp: Date
    
    var rating: String {
        switch score {
        case 9.0...10.0:
            return "Excellent"
        case 7.0..<9.0:
            return "Very Good"
        case 5.0..<7.0:
            return "Good"
        case 3.0..<5.0:
            return "Fair"
        default:
            return "Poor"
        }
    }
}

struct TraceData: Codable {
    let ip: String
    let country: String
    let pop: String?
    let warp: Bool?
}

struct WARPStatus: Codable {
    let enabled: Bool
    let mode: String?
}

// MARK: - Usage Example

/*
let engine = OptimizedHealthScoringEngine()

let dnsLatencies = ["cloudflare": 12, "google": 18, "quad9": 15, "nextdns": 22]
let dohLatencies = ["cloudflare": 25, "google": 30]
let trace = TraceData(ip: "1.1.1.1", country: "US", pop: "LAX", warp: true)
let warp = WARPStatus(enabled: true, mode: "WARP+")

// First call calculates
let score1 = engine.calculateHealthScoreCached(
    dnsLatencies: dnsLatencies,
    dohLatencies: dohLatencies,
    traceData: trace,
    warpStatus: warp
)  // ~5ms

// Second call returns cached result
let score2 = engine.calculateHealthScoreCached(
    dnsLatencies: dnsLatencies,
    dohLatencies: dohLatencies,
    traceData: trace,
    warpStatus: warp
)  // <1ms (from cache)

engine.printCacheStats()
*/
