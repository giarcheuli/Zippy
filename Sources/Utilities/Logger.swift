import Foundation
import OSLog

struct Logger {
    private static let logger = os.Logger(subsystem: Constants.Logging.subsystem, category: Constants.Logging.category)
    
    enum LogLevel {
        case debug
        case info
        case warning
        case error
        
        var osLogType: OSLogType {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            }
        }
    }
    
    static func log(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "[\(fileName):\(line) \(function)] \(message)"
        
        switch level {
        case .debug:
            logger.debug("\(logMessage)")
        case .info:
            logger.info("\(logMessage)")
        case .warning:
            logger.warning("\(logMessage)")
        case .error:
            logger.error("\(logMessage)")
        }
    }
    
    // Convenience methods
    static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
    
    // Specific logging methods for common operations
    static func logFileOperation(_ operation: String, path: String, success: Bool, errorMessage: String? = nil) {
        let message = "\(operation) \(success ? "succeeded" : "failed") for: \(path)"
        if success {
            info(message)
        } else {
            error("\(message) - Error: \(errorMessage ?? "Unknown")")
        }
    }
    
    static func logZipOperation(_ operation: String, archivePath: String, success: Bool, errorMessage: String? = nil) {
        let message = "Zip \(operation) \(success ? "succeeded" : "failed") for archive: \(archivePath)"
        if success {
            info(message)
        } else {
            error("\(message) - Error: \(errorMessage ?? "Unknown")")
        }
    }
    
    static func logUIAction(_ action: String, details: String? = nil) {
        let message = "UI Action: \(action)\(details.map { " - \($0)" } ?? "")"
        debug(message)
    }
    
    static func logPerformance(_ operation: String, duration: TimeInterval) {
        info("Performance: \(operation) completed in \(String(format: "%.2f", duration))s")
    }
}