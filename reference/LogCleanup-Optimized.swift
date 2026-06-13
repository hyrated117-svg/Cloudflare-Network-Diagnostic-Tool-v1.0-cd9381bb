//
// LogCleanup-Optimized.swift
// Efficient 30-Day Log Cleanup
//
// ISSUE: Scanning all logs sequentially for deletion can stall app
// SOLUTION: Batch delete with date-based indexing and async operations
//

import Foundation

class OptimizedLogCleanupManager {
    
    let logsDirectory: URL
    let fileManager = FileManager.default
    
    init(logsDirectory: URL) {
        self.logsDirectory = logsDirectory
        try? fileManager.createDirectory(
            at: logsDirectory,
            withIntermediateDirectories: true
        )
    }
    
    // MARK: - Problematic Pattern (DO NOT USE)
    
    /// ❌ SLOW: Checks modification time of every log file
    func cleanupLogsSlowBlocking(olderThanDays days: Int = 30) {
        """
        SLOW: O(n) operation that blocks the main thread.
        Checks modification time for every log file in the directory.
        """
        let cutoffDate = Date(timeIntervalSinceNow: -Double(days * 24 * 3600))
        
        do {
            let files = try fileManager.contentsOfDirectory(
                at: logsDirectory,
                includingPropertiesForKeys: [.contentModificationDateKey]
            )
            
            for file in files {
                guard file.pathExtension == "cflog" else { continue }
                
                // Get modification date (I/O operation)
                if let attrs = try? fileManager.attributesOfItem(atPath: file.path),
                   let modDate = attrs[.modificationDate] as? Date,
                   modDate < cutoffDate {
                    try fileManager.removeItem(at: file)  // Delete
                }
            }
        } catch {
            print("Error during log cleanup: \(error)")
        }
    }
    
    // MARK: - Optimized Pattern: Date-Based Batching
    
    /// ✅ FAST: Uses filename date prefix for efficient filtering
    func cleanupLogsFastAsync(
        olderThanDays days: Int = 30,
        batchSize: Int = 50
    ) async {
        """
        FAST: Non-blocking cleanup using date-based batch deletion.
        Extracts date from filename (no I/O needed to check dates).
        """
        let cutoffDate = Date(timeIntervalSinceNow: -Double(days * 24 * 3600))
        let cutoffDateString = ISO8601DateFormatter().string(
            from: cutoffDate
        ).prefix(10)  // YYYY-MM-DD
        
        do {
            let files = try fileManager.contentsOfDirectory(
                at: logsDirectory,
                includingPropertiesForKeys: nil
            )
            
            // Filter old logs by filename (no I/O needed)
            let oldLogs = files.filter { file in
                guard file.pathExtension == "cflog" else { return false }
                
                // Extract date from filename: diagnostic_YYYY-MM-DDTHH:MM:SS.cflog
                let filename = file.lastPathComponent
                let datePrefix = filename.dropFirst(11).prefix(10)  // YYYY-MM-DD
                
                return datePrefix < cutoffDateString
            }
            
            // Delete in batches on background thread
            await deleteBatch(oldLogs, batchSize: batchSize)
            
            print("Cleaned up \(oldLogs.count) logs older than \(days) days")
        } catch {
            print("Error during log cleanup: \(error)")
        }
    }
    
    // MARK: - Batch Deletion Helper
    
    private func deleteBatch(_ files: [URL], batchSize: Int) async {
        // Delete in batches on background thread
        for batch in files.chunked(into: batchSize) {
            await withCheckedContinuation { continuation in
                DispatchQueue.global(qos: .background).async {
                    for file in batch {
                        try? self.fileManager.removeItem(at: file)
                    }
                    continuation.resume()
                }
            }
            
            // Yield to prevent blocking system
            try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1 seconds
        }
    }
    
    // MARK: - Advanced Pattern: Schedule Periodic Cleanup
    
    /// ✅ BEST: Automatic cleanup scheduled periodically
    func schedulePeriodicCleanup(
        interval: TimeInterval = 24 * 3600,  // Daily
        olderThanDays: Int = 30
    ) {
        """
        BEST: Run cleanup automatically at intervals without blocking user.
        """
        Task {
            while true {
                // Sleep for interval duration
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                
                // Run cleanup on background thread
                await cleanupLogsFastAsync(olderThanDays: olderThanDays)
            }
        }
    }
    
    // MARK: - Log Statistics
    
    /// Get cleanup statistics without modifying files
    func getCleanupStats(olderThanDays days: Int = 30) async -> CleanupStats {
        let cutoffDate = Date(timeIntervalSinceNow: -Double(days * 24 * 3600))
        let cutoffDateString = ISO8601DateFormatter().string(
            from: cutoffDate
        ).prefix(10)
        
        do {
            let files = try fileManager.contentsOfDirectory(
                at: logsDirectory,
                includingPropertiesForKeys: [.fileSizeKey]
            )
            
            var totalSize: Int = 0
            var oldCount = 0
            var recentCount = 0
            var oldSize: Int = 0
            var recentSize: Int = 0
            
            for file in files {
                guard file.pathExtension == "cflog" else { continue }
                
                let fileSize = (try? fileManager.attributesOfItem(
                    atPath: file.path
                ))?[.size] as? Int ?? 0
                
                totalSize += fileSize
                
                let filename = file.lastPathComponent
                let datePrefix = filename.dropFirst(11).prefix(10)
                
                if datePrefix < cutoffDateString {
                    oldCount += 1
                    oldSize += fileSize
                } else {
                    recentCount += 1
                    recentSize += fileSize
                }
            }
            
            return CleanupStats(
                totalFiles: files.filter { $0.pathExtension == "cflog" }.count,
                totalSize: totalSize,
                oldFiles: oldCount,
                oldSize: oldSize,
                recentFiles: recentCount,
                recentSize: recentSize,
                olderThanDays: days
            )
        } catch {
            print("Error getting cleanup stats: \(error)")
            return CleanupStats(
                totalFiles: 0,
                totalSize: 0,
                oldFiles: 0,
                oldSize: 0,
                recentFiles: 0,
                recentSize: 0,
                olderThanDays: days
            )
        }
    }
}

// MARK: - Data Models

struct CleanupStats {
    let totalFiles: Int
    let totalSize: Int
    let oldFiles: Int
    let oldSize: Int
    let recentFiles: Int
    let recentSize: Int
    let olderThanDays: Int
    
    var description: String {
        return """
        Log Cleanup Statistics:
        - Total files: \(totalFiles)
        - Total size: \(formatBytes(totalSize))
        - Old files (>\(olderThanDays) days): \(oldFiles)
        - Old size: \(formatBytes(oldSize))
        - Recent files: \(recentFiles)
        - Recent size: \(formatBytes(recentSize))
        - Storage savings if cleaned: \(formatBytes(oldSize))
        """
    }
    
    private func formatBytes(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

// MARK: - Array Chunking Extension

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - Usage Example

/*
let logManager = OptimizedLogCleanupManager(
    logsDirectory: FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    )[0].appendingPathComponent("Logs")
)

// Option 1: Run cleanup immediately (non-blocking)
Task {
    await logManager.cleanupLogsFastAsync(olderThanDays: 30)
}

// Option 2: Get statistics before cleanup
Task {
    let stats = await logManager.getCleanupStats(olderThanDays: 30)
    print(stats.description)
}

// Option 3: Schedule periodic automatic cleanup
logManager.schedulePeriodicCleanup(interval: 24 * 3600, olderThanDays: 30)
*/
