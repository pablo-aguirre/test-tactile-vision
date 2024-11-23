//
//  FileLogger.swift
//  AR Sync Test
//
//  Created by Pablo Aguirre on 22/11/24.
//

import Foundation
import os

class FileLogger {
    private var logEntries: [String] = []
    private let fileManager = FileManager.default
    private let logger: Logger = .init()
    
    func log(entry: String) {
        logEntries.append(entry)
        logger.info("\(entry)")
    }
    
    func saveToFile() {
        guard !logEntries.isEmpty else { return }
        
        do {
            let documentsDirectory = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            
            let fileURL = documentsDirectory.appendingPathComponent("session_log_\(Date().description).csv")
            
            let logContent = logEntries.joined(separator: "\n")
            try logContent.write(to: fileURL, atomically: true, encoding: .utf8)
            
            logger.info("Save log file to \(fileURL.path)")
            logEntries.removeAll()
        } catch {
            logger.error("Error saving log file: \(error.localizedDescription)")
        }
    }
}
