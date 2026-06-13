//
// NetworkLayer-Optimized.swift
// Parallel DNS Benchmarking with async/await
//
// ISSUE: Sequential DNS lookups cause 67ms latency instead of 22ms
// SOLUTION: Run all DNS tests concurrently using Swift async/await
//

import Foundation

// MARK: - Optimized URLSession Configuration

class OptimizedNetworkLayer {
    
    // ✅ FIXED: Explicit timeout configuration prevents hanging
    static let optimizedSessionConfig: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5.0        // Individual request timeout
        config.timeoutIntervalForResource = 30.0      // Total resource timeout
        config.httpMaximumConnectionsPerHost = 6      // Connection pooling
        config.waitsForConnectivity = false            // Fail fast on no connectivity
        return config
    }()
    
    static let optimizedSession = URLSession(configuration: optimizedSessionConfig)
    
    // MARK: - Parallel DNS Benchmarking
    
    /// ❌ SLOW: Sequential DNS lookups (~67ms total)
    /// DO NOT USE THIS PATTERN
    func benchmarkResolversSequential() async throws -> [String: Int] {
        var results: [String: Int] = [:]
        
        // Each DNS lookup blocks until complete
        results["cloudflare"] = try await measureDNS(resolver: .cloudflare)  // ~12ms
        results["google"] = try await measureDNS(resolver: .google)          // ~18ms
        results["quad9"] = try await measureDNS(resolver: .quad9)            // ~15ms
        results["nextdns"] = try await measureDNS(resolver: .nextdns)        // ~22ms
        
        // Total: ~67ms ⚠️ TOO SLOW
        return results
    }
    
    /// ✅ FAST: Parallel DNS lookups (~22ms total)
    /// USE THIS PATTERN
    func benchmarkResolversParallel() async throws -> [String: Int] {
        // Start all DNS lookups concurrently
        async let cfLatency = measureDNS(resolver: .cloudflare)
        async let googleLatency = measureDNS(resolver: .google)
        async let quad9Latency = measureDNS(resolver: .quad9)
        async let nextLatency = measureDNS(resolver: .nextdns)
        
        // Wait for all to complete (in parallel)
        let (cf, google, quad9, next) = try await (
            cfLatency,
            googleLatency,
            quad9Latency,
            nextLatency
        )
        
        // Total: ~22ms (the longest individual test) ✅ 3x FASTER
        return [
            "cloudflare": cf,
            "google": google,
            "quad9": quad9,
            "nextdns": next
        ]
    }
    
    // MARK: - Task Group Pattern (for dynamic resolver lists)
    
    /// ✅ BEST: Using TaskGroup for flexible parallel execution
    func benchmarkResolversWithTaskGroup(
        resolvers: [DNSResolver]
    ) async throws -> [String: Int] {
        var results: [String: Int] = [:]
        
        // Use TaskGroup to run multiple tasks concurrently
        try await withThrowingTaskGroup(of: (String, Int).self) { group in
            for resolver in resolvers {
                group.addTask {
                    let latency = try await self.measureDNS(resolver: resolver)
                    return (resolver.name, latency)
                }
            }
            
            // Collect results as they complete (no blocking)
            for try await (name, latency) in group {
                results[name] = latency
            }
        }
        
        return results
    }
    
    // MARK: - DoH (DNS-over-HTTPS) Parallel Testing
    
    /// ✅ FAST: Parallel DoH benchmarking
    func benchmarkDoHResolversParallel() async throws -> [String: Int] {
        async let cfDoH = measureDoH(resolver: .cloudflare)
        async let googleDoH = measureDoH(resolver: .google)
        async let quad9DoH = measureDoH(resolver: .quad9)
        
        let (cf, google, quad9) = try await (
            cfDoH,
            googleDoH,
            quad9DoH
        )
        
        return [
            "cloudflare_doh": cf,
            "google_doh": google,
            "quad9_doh": quad9
        ]
    }
    
    // MARK: - Combined Parallel Execution
    
    /// ✅ BEST: Run DNS and DoH benchmarks in parallel
    func runAllBenchmarksParallel() async throws -> BenchmarkResults {
        async let dns = benchmarkResolversParallel()
        async let doh = benchmarkDoHResolversParallel()
        async let trace = fetchCloudflareTrace()
        async let warp = detectWARP()
        
        let (dnsResults, dohResults, traceData, warpStatus) = try await (
            dns,
            doh,
            trace,
            warp
        )
        
        return BenchmarkResults(
            dns: dnsResults,
            doh: dohResults,
            trace: traceData,
            warp: warpStatus
        )
    }
    
    // MARK: - Helper Methods
    
    private func measureDNS(resolver: DNSResolver) async throws -> Int {
        let startTime = Date()
        
        let url = resolver.dnsQueryURL
        let (data, _) = try await Self.optimizedSession.data(from: url)
        
        let latency = Int(Date().timeIntervalSince(startTime) * 1000) // ms
        return latency
    }
    
    private func measureDoH(resolver: DNSResolver) async throws -> Int {
        let startTime = Date()
        
        var request = URLRequest(url: resolver.dohURL)
        request.httpMethod = "POST"
        request.setValue("application/dns-message", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 5.0
        
        let (data, _) = try await Self.optimizedSession.data(for: request)
        
        let latency = Int(Date().timeIntervalSince(startTime) * 1000) // ms
        return latency
    }
    
    private func fetchCloudflareTrace() async throws -> TraceData {
        let url = URL(string: "https://one.one.one.one/api/doh/trace")!
        let (data, _) = try await Self.optimizedSession.data(from: url)
        let trace = try JSONDecoder().decode(TraceData.self, from: data)
        return trace
    }
    
    private func detectWARP() async throws -> WARPStatus {
        // Check various WARP indicators
        // Implementation depends on your WARP detection logic
        return WARPStatus(enabled: false, mode: .off)
    }
}

// MARK: - Data Models

enum DNSResolver {
    case cloudflare
    case google
    case quad9
    case nextdns
    
    var name: String {
        switch self {
        case .cloudflare: return "cloudflare"
        case .google: return "google"
        case .quad9: return "quad9"
        case .nextdns: return "nextdns"
        }
    }
    
    var dnsQueryURL: URL {
        switch self {
        case .cloudflare:
            return URL(string: "https://1.1.1.1/dns-query?name=example.com&type=A")!
        case .google:
            return URL(string: "https://8.8.8.8:5053/dns-query?name=example.com&type=A")!
        case .quad9:
            return URL(string: "https://9.9.9.9/dns-query?name=example.com&type=A")!
        case .nextdns:
            return URL(string: "https://dns.nextdns.io/dns-query?name=example.com&type=A")!
        }
    }
    
    var dohURL: URL {
        switch self {
        case .cloudflare:
            return URL(string: "https://cloudflare-dns.com/dns-query")!
        case .google:
            return URL(string: "https://dns.google/dns-query")!
        case .quad9:
            return URL(string: "https://dns.quad9.net/dns-query")!
        case .nextdns:
            return URL(string: "https://dns.nextdns.io/dns-query")!
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
    enum Mode: String, Codable {
        case off
        case warp
        case warpPlus = "warp+"
    }
    
    let enabled: Bool
    let mode: Mode
}

struct BenchmarkResults: Codable {
    let dns: [String: Int]
    let doh: [String: Int]
    let trace: TraceData
    let warp: WARPStatus
}

// MARK: - Usage Example

/*
 // In your ViewController or SwiftUI View
 
 @main
 struct DiagnosticApp: App {
     @State private var isRunning = false
     @State private var results: BenchmarkResults?
     
     var body: some Scene {
         WindowGroup {
             VStack {
                 Button("Run Diagnostics") {
                     Task {
                         isRunning = true
                         do {
                             let networkLayer = OptimizedNetworkLayer()
                             results = try await networkLayer.runAllBenchmarksParallel()
                         } catch {
                             print("Error: \(error)")
                         }
                         isRunning = false
                     }
                 }
                 .disabled(isRunning)
                 
                 if let results = results {
                     Text("DNS Results: \(results.dns)")
                     Text("DoH Results: \(results.doh)")
                 }
             }
         }
     }
 }
 
*/
