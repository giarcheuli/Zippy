import XCTest
@testable import Zippy

final class ZippyErrorTests: XCTestCase {
    
    func testErrorDescriptions() {
        // Test that all error cases have proper descriptions
        let fileNotFound = ZippyError.fileNotFound(path: "/test/path")
        XCTAssertEqual(fileNotFound.errorDescription, "File not found: /test/path")
        
        let permissionDenied = ZippyError.permissionDenied(path: "/restricted/path")
        XCTAssertEqual(permissionDenied.errorDescription, "Permission denied: /restricted/path")
        
        let invalidPath = ZippyError.invalidPath(path: "../invalid")
        XCTAssertEqual(invalidPath.errorDescription, "Invalid path: ../invalid")
        
        let invalidArchiveName = ZippyError.invalidArchiveName(name: "bad<name>.zip")
        XCTAssertEqual(invalidArchiveName.errorDescription, "Invalid archive name: bad<name>.zip")
        
        let directoryNotFound = ZippyError.directoryNotFound(path: "/missing/dir")
        XCTAssertEqual(directoryNotFound.errorDescription, "Directory not found: /missing/dir")
        
        let archiveCreationFailed = ZippyError.archiveCreationFailed(reason: "Disk full")
        XCTAssertEqual(archiveCreationFailed.errorDescription, "Failed to create archive: Disk full")
        
        let archiveExtractionFailed = ZippyError.archiveExtractionFailed(reason: "Corrupted file")
        XCTAssertEqual(archiveExtractionFailed.errorDescription, "Failed to extract archive: Corrupted file")
        
        let archiveReadFailed = ZippyError.archiveReadFailed(reason: "Invalid format")
        XCTAssertEqual(archiveReadFailed.errorDescription, "Failed to read archive: Invalid format")
        
        let invalidArchiveFormat = ZippyError.invalidArchiveFormat
        XCTAssertEqual(invalidArchiveFormat.errorDescription, "Invalid archive format")
        
        let operationCancelled = ZippyError.operationCancelled
        XCTAssertEqual(operationCancelled.errorDescription, "Operation cancelled")
        
        let unknown = ZippyError.unknown(reason: "Something went wrong")
        XCTAssertEqual(unknown.errorDescription, "Unknown error: Something went wrong")
    }
    
    func testRecoverySuggestions() {
        // Test that all error cases have helpful recovery suggestions
        let fileNotFound = ZippyError.fileNotFound(path: "/test/path")
        XCTAssertEqual(fileNotFound.recoverySuggestion, "Check if the file exists and try again.")
        
        let permissionDenied = ZippyError.permissionDenied(path: "/restricted/path")
        XCTAssertEqual(permissionDenied.recoverySuggestion, "Check file permissions or try running with elevated privileges.")
        
        let invalidPath = ZippyError.invalidPath(path: "../invalid")
        XCTAssertEqual(invalidPath.recoverySuggestion, "Verify the path is correct and accessible.")
        
        let invalidArchiveName = ZippyError.invalidArchiveName(name: "bad<name>.zip")
        XCTAssertEqual(invalidArchiveName.recoverySuggestion, "Use a valid filename without special characters like /\\:*?\"<>|")
        
        let directoryNotFound = ZippyError.directoryNotFound(path: "/missing/dir")
        XCTAssertEqual(directoryNotFound.recoverySuggestion, "Ensure the directory exists or create it first.")
        
        let archiveCreationFailed = ZippyError.archiveCreationFailed(reason: "Disk full")
        XCTAssertEqual(archiveCreationFailed.recoverySuggestion, "Try again or check the file for corruption.")
        
        let archiveExtractionFailed = ZippyError.archiveExtractionFailed(reason: "Corrupted file")
        XCTAssertEqual(archiveExtractionFailed.recoverySuggestion, "Try again or check the file for corruption.")
        
        let archiveReadFailed = ZippyError.archiveReadFailed(reason: "Invalid format")
        XCTAssertEqual(archiveReadFailed.recoverySuggestion, "Try again or check the file for corruption.")
        
        let invalidArchiveFormat = ZippyError.invalidArchiveFormat
        XCTAssertEqual(invalidArchiveFormat.recoverySuggestion, "Ensure the file is a valid ZIP archive.")
        
        let operationCancelled = ZippyError.operationCancelled
        XCTAssertEqual(operationCancelled.recoverySuggestion, "The operation was cancelled by the user.")
        
        let unknown = ZippyError.unknown(reason: "Something went wrong")
        XCTAssertEqual(unknown.recoverySuggestion, "Please try again or contact support if the problem persists.")
    }
    
    func testLocalizedErrorConformance() {
        // Test that ZippyError conforms to LocalizedError
        let error = ZippyError.fileNotFound(path: "/test/path")
        
        XCTAssertNotNil(error.errorDescription)
        XCTAssertNotNil(error.recoverySuggestion)
        XCTAssertTrue(error is LocalizedError)
    }
}