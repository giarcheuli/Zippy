import Foundation

enum ZippyError: LocalizedError {
    case fileNotFound(path: String)
    case permissionDenied(path: String)
    case invalidPath(path: String)
    case invalidArchiveName(name: String)
    case directoryNotFound(path: String)
    case archiveCreationFailed(reason: String)
    case archiveExtractionFailed(reason: String)
    case archiveReadFailed(reason: String)
    case invalidArchiveFormat
    case operationCancelled
    case unknown(reason: String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .permissionDenied(let path):
            return "Permission denied: \(path)"
        case .invalidPath(let path):
            return "Invalid path: \(path)"
        case .invalidArchiveName(let name):
            return "Invalid archive name: \(name)"
        case .directoryNotFound(let path):
            return "Directory not found: \(path)"
        case .archiveCreationFailed(let reason):
            return "Failed to create archive: \(reason)"
        case .archiveExtractionFailed(let reason):
            return "Failed to extract archive: \(reason)"
        case .archiveReadFailed(let reason):
            return "Failed to read archive: \(reason)"
        case .invalidArchiveFormat:
            return "Invalid archive format"
        case .operationCancelled:
            return "Operation cancelled"
        case .unknown(let reason):
            return "Unknown error: \(reason)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .fileNotFound:
            return "Check if the file exists and try again."
        case .permissionDenied:
            return "Check file permissions or try running with elevated privileges."
        case .invalidPath:
            return "Verify the path is correct and accessible."
        case .invalidArchiveName:
            return "Use a valid filename without special characters like /\\:*?\"<>|"
        case .directoryNotFound:
            return "Ensure the directory exists or create it first."
        case .archiveCreationFailed, .archiveExtractionFailed, .archiveReadFailed:
            return "Try again or check the file for corruption."
        case .invalidArchiveFormat:
            return "Ensure the file is a valid ZIP archive."
        case .operationCancelled:
            return "The operation was cancelled by the user."
        case .unknown:
            return "Please try again or contact support if the problem persists."
        }
    }
}