//
// ExportLayer-Optimized.swift
// Background Thread JSON Exports
//
// ISSUE: JSON encoding/pretty-printing blocks UI for 100-500ms on large datasets
// SOLUTION: Move all export operations to background thread with DispatchQueue
//

import Foundation

class OptimizedExportLayer {
    
    // MARK: - Export Format Types
    
    enum ExportFormat {
        case json
        case jsonMinified
        case jsonPretty
        case jsonl  // JSON Lines
        case masterDict
        case developerConsole
    }
    
    // MARK: - Problematic Pattern (DO NOT USE)
    
    /// ❌ BLOCKS UI: All encoding on main thread
    func exportDiagnosticsBlocking(
        diagnostics: [String: Any],
        format: ExportFormat
    ) -> String? {
        // ⚠️ This blocks the main thread for 100-500ms on large datasets
        switch format {
        case .json, .jsonMinified, .jsonPretty:
            guard let jsonData = try? JSONSerialization.data(
                withJSONObject: diagnostics,
                options: format == .jsonPretty ? .prettyPrinted : []
            ) else { return nil }
            return String(data: jsonData, encoding: .utf8)
            
        case .jsonl:
            // JSONL encoding on main thread ⚠️
            return encodeJSONL(diagnostics)
            
        default:
            return nil
        }
    }
    
    // MARK: - Optimized Pattern (USE THIS)
    
    /// ✅ NON-BLOCKING: Background thread export with completion handler
    func exportDiagnosticsAsync(
        diagnostics: [String: Any],
        format: ExportFormat,
        completion: @escaping (String?, Error?) -> Void
    ) {
        // Move work to background thread
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let result = try self._performExport(
                    diagnostics: diagnostics,
                    format: format
                )
                
                // Deliver result on main thread
                DispatchQueue.main.async {
                    completion(result, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    /// ✅ BEST: Modern async/await pattern (Swift 5.5+)
    func exportDiagnosticsAsyncAwait(
        diagnostics: [String: Any],
        format: ExportFormat
    ) async throws -> String {
        // Dispatch to background thread and await result
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let result = try self._performExport(
                        diagnostics: diagnostics,
                        format: format
                    )
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Streaming Export (for large datasets)
    
    /// ✅ MEMORY EFFICIENT: Stream results to file instead of buffering in memory
    func exportDiagnosticsStreaming(
        diagnosticsArray: [[String: Any]],
        format: ExportFormat,
        toFileURL fileURL: URL,
        progressCallback: ((Int) -> Void)? = nil
    ) async throws {
        let fileHandle = try FileHandle(forWritingTo: fileURL)
        defer { try? fileHandle.close() }
        
        try fileHandle.seekToEndOfFile()
        
        switch format {
        case .jsonl:
            // Stream JSONL line by line (memory efficient)
            for (index, dict) in diagnosticsArray.enumerated() {
                if let jsonData = try? JSONSerialization.data(
                    withJSONObject: dict,
                    options: []
                ),
                   var jsonString = String(data: jsonData, encoding: .utf8) {
                    
                    jsonString.append("\n")
                    if let lineData = jsonString.data(using: .utf8) {
                        fileHandle.write(lineData)
                    }
                }
                
                // Update progress every 100 items
                if index % 100 == 0 {
                    progressCallback?(index)
                }
            }
            
        case .jsonPretty:
            // For large arrays, stream pretty JSON
            try fileHandle.write(contentsOf: "[\n".data(using: .utf8)!)
            
            for (index, dict) in diagnosticsArray.enumerated() {
                if let jsonData = try? JSONSerialization.data(
                    withJSONObject: dict,
                    options: .prettyPrinted
                ),
                   var jsonString = String(data: jsonData, encoding: .utf8) {
                    
                    if index < diagnosticsArray.count - 1 {
                        jsonString.append(",\n")
                    } else {
                        jsonString.append("\n")
                    }
                    
                    if let lineData = jsonString.data(using: .utf8) {
                        fileHandle.write(lineData)
                    }
                }
                
                if index % 100 == 0 {
                    progressCallback?(index)
                }
            }
            
            try fileHandle.write(contentsOf: "]".data(using: .utf8)!)
            
        default:
            throw ExportError.unsupportedFormat
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func _performExport(
        diagnostics: [String: Any],
        format: ExportFormat
    ) throws -> String {
        switch format {
        case .json:
            let jsonData = try JSONSerialization.data(
                withJSONObject: diagnostics,
                options: []
            )
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw ExportError.encodingFailed
            }
            return jsonString
            
        case .jsonMinified:
            let jsonData = try JSONSerialization.data(
                withJSONObject: diagnostics,
                options: [.sortedKeys]
            )
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw ExportError.encodingFailed
            }
            return jsonString
            
        case .jsonPretty:
            let jsonData = try JSONSerialization.data(
                withJSONObject: diagnostics,
                options: [.prettyPrinted, .sortedKeys]
            )
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw ExportError.encodingFailed
            }
            return jsonString
            
        case .jsonl:
            return try encodeJSONL(diagnostics)
            
        case .masterDict:
            return String(describing: diagnostics)
            
        case .developerConsole:
            return formatDeveloperConsole(diagnostics)
        }
    }
    
    private func encodeJSONL(_ dict: [String: Any]) throws -> String {
        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw ExportError.encodingFailed
        }
        return jsonString + "\n"
    }
    
    private func formatDeveloperConsole(_ dict: [String: Any]) -> String {
        var output = ""
        output += "\n━━━━━━━━━━━━━━━━━━━━━��━━━━━━━━━━━━━━━━━━━━\n"
        output += "  CLOUDFLARE NETWORK DIAGNOSTIC REPORT\n"
        output += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
        
        for (key, value) in dict {
            output += "\(key.uppercased()): \(value)\n"
        }
        
        output += "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        return output
    }
}

// MARK: - Error Handling

enum ExportError: Error {
    case encodingFailed
    case writeFailed
    case unsupportedFormat
}

// MARK: - SwiftUI Integration Example

/*
import SwiftUI

struct ExportView: View {
    @State private var diagnosticData: [String: Any] = [:]
    @State private var isExporting = false
    @State private var exportedText: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            Button("Export as JSON") {
                exportWithBackground(format: .json)
            }
            .disabled(isExporting)
            
            Button("Export as Pretty JSON") {
                exportWithAsyncAwait(format: .jsonPretty)
            }
            .disabled(isExporting)
            
            if isExporting {
                ProgressView("Exporting...")
            }
            
            if !exportedText.isEmpty {
                ScrollView {
                    Text(exportedText)
                        .font(.system(.caption, design: .monospaced))
                }
            }
        }
        .alert("Export Result", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func exportWithBackground(format: OptimizedExportLayer.ExportFormat) {
        isExporting = true
        let exporter = OptimizedExportLayer()
        
        exporter.exportDiagnosticsAsync(
            diagnostics: diagnosticData,
            format: format
        ) { result, error in
            isExporting = false
            if let result = result {
                exportedText = result
                alertMessage = "Export successful!"
            } else if let error = error {
                alertMessage = "Export failed: \(error.localizedDescription)"
            }
            showAlert = true
        }
    }
    
    private func exportWithAsyncAwait(format: OptimizedExportLayer.ExportFormat) {
        isExporting = true
        let exporter = OptimizedExportLayer()
        
        Task {
            do {
                exportedText = try await exporter.exportDiagnosticsAsyncAwait(
                    diagnostics: diagnosticData,
                    format: format
                )
                alertMessage = "Export successful!"
            } catch {
                alertMessage = "Export failed: \(error.localizedDescription)"
            }
            isExporting = false
            showAlert = true
        }
    }
}
*/
