import XCTest
@testable import Zippy

final class ValidationTests: XCTestCase {
    
    func testValidPath() {
        // Valid paths should return true
        XCTAssertTrue(Validation.isValidPath("/Users/test/file.txt"))
        XCTAssertTrue(Validation.isValidPath("relative/path/file.zip"))
        XCTAssertTrue(Validation.isValidPath("file.txt"))
    }
    
    func testInvalidPathWithDirectoryTraversal() {
        // Paths with directory traversal should be invalid
        XCTAssertFalse(Validation.isValidPath("../etc/passwd"))
        XCTAssertFalse(Validation.isValidPath("../../secret.txt"))
        XCTAssertFalse(Validation.isValidPath("../../../root"))
    }
    
    func testInvalidPathWithDangerousCharacters() {
        // Paths with null bytes, newlines, etc. should be invalid
        XCTAssertFalse(Validation.isValidPath("file.txt\0"))
        XCTAssertFalse(Validation.isValidPath("file.txt\n"))
        XCTAssertFalse(Validation.isValidPath("file.txt\r"))
        XCTAssertFalse(Validation.isValidPath("file.txt~"))
    }
    
    func testEmptyPath() {
        // Empty paths should be invalid
        XCTAssertFalse(Validation.isValidPath(""))
    }
    
    func testPathTooLong() {
        // Paths longer than max length should be invalid
        let longPath = String(repeating: "a", count: Constants.Validation.maxPathLength + 1)
        XCTAssertFalse(Validation.isValidPath(longPath))
    }
    
    func testValidArchiveName() {
        // Valid archive names should return true
        XCTAssertTrue(Validation.isValidArchiveName("archive.zip"))
        XCTAssertTrue(Validation.isValidArchiveName("my-file_123.zip"))
        XCTAssertTrue(Validation.isValidArchiveName("test.ZIP"))
    }
    
    func testInvalidArchiveName() {
        // Invalid archive names should return false
        XCTAssertFalse(Validation.isValidArchiveName("")) // Empty
        XCTAssertFalse(Validation.isValidArchiveName("file/with/slashes.zip")) // Contains slashes
        XCTAssertFalse(Validation.isValidArchiveName("file*with*stars.zip")) // Invalid characters
        XCTAssertFalse(Validation.isValidArchiveName("file:with:colons.zip"))
        XCTAssertFalse(Validation.isValidArchiveName("file?with?questions.zip"))
        XCTAssertFalse(Validation.isValidArchiveName("file\"with\"quotes.zip"))
        XCTAssertFalse(Validation.isValidArchiveName("file<with>brackets.zip"))
        XCTAssertFalse(Validation.isValidArchiveName("file|with|pipes.zip"))
    }
    
    func testArchiveNameTooLong() {
        // Archive names longer than max length should be invalid
        let longName = String(repeating: "a", count: Constants.Validation.maxArchiveNameLength + 1) + ".zip"
        XCTAssertFalse(Validation.isValidArchiveName(longName))
    }
    
    func testSanitizePath() {
        // Test path sanitization
        XCTAssertEqual(Validation.sanitizePath("path/with\0null"), "path/withnull")
        XCTAssertEqual(Validation.sanitizePath("path/with\nnewline"), "path/withnewline")
        XCTAssertEqual(Validation.sanitizePath("path/with\rreturn"), "path/withreturn")
        XCTAssertEqual(Validation.sanitizePath("  path/with/spaces  "), "path/with/spaces")
    }
    
    func testValidateDestinationDirectory() {
        // Test with a valid directory (using temp directory)
        let tempDir = FileManager.default.temporaryDirectory
        let result = Validation.validateDestinationDirectory(tempDir.path)
        
        switch result {
        case .success(let path):
            XCTAssertEqual(path, tempDir.path)
        case .failure:
            XCTFail("Valid directory should succeed")
        }
    }
    
    func testValidateDestinationDirectoryInvalid() {
        // Test with invalid path
        let result = Validation.validateDestinationDirectory("../invalid/path")
        
        switch result {
        case .success:
            XCTFail("Invalid path should fail")
        case .failure(let error):
            XCTAssertTrue(error.localizedDescription.contains("Invalid path"))
        }
    }
}