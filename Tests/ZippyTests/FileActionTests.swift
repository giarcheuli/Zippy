import XCTest
@testable import Zippy

final class FileActionTests: XCTestCase {
    
    func testFileActionsStruct() {
        // Test FileActions struct
        let fileItem = FileItem(
            name: "test.zip",
            path: "/test/test.zip",
            size: 1024,
            dateModified: Date(),
            isDirectory: false,
            isZipFile: true
        )
        
        let actions = FileActions(file: fileItem, isMultiSelect: false)
        
        // For zip files, should have preview and extract actions
        XCTAssertTrue(actions.availableActions.contains(.preview))
        XCTAssertTrue(actions.availableActions.contains(.extract))
        XCTAssertFalse(actions.availableActions.contains(.open)) // Not for files
    }
    
    func testFileActionsForDirectory() {
        let dirItem = FileItem(
            name: "testdir",
            path: "/test/testdir",
            size: 0,
            dateModified: Date(),
            isDirectory: true,
            isZipFile: false
        )
        
        let actions = FileActions(file: dirItem, isMultiSelect: false)
        
        // For directories, should have open action
        XCTAssertTrue(actions.availableActions.contains(.open))
        XCTAssertFalse(actions.availableActions.contains(.preview)) // Not for directories
        XCTAssertFalse(actions.availableActions.contains(.extract)) // Not for directories
    }
    
    func testFileActionsForRegularFile() {
        let fileItem = FileItem(
            name: "test.txt",
            path: "/test/test.txt",
            size: 100,
            dateModified: Date(),
            isDirectory: false,
            isZipFile: false
        )
        
        let actions = FileActions(file: fileItem, isMultiSelect: false)
        
        // For regular files, should have zip action
        XCTAssertTrue(actions.availableActions.contains(.zip))
        XCTAssertFalse(actions.availableActions.contains(.preview))
        XCTAssertFalse(actions.availableActions.contains(.extract))
    }
    
    func testFileActionsMultiSelect() {
        let fileItem = FileItem(
            name: "test.zip",
            path: "/test/test.zip",
            size: 1024,
            dateModified: Date(),
            isDirectory: false,
            isZipFile: true
        )
        
        let actions = FileActions(file: fileItem, isMultiSelect: true)
        
        // In multi-select mode, should not show individual actions
        XCTAssertTrue(actions.availableActions.isEmpty)
    }
    
    func testFileActionProperties() {
        // Test FileAction enum properties
        XCTAssertEqual(FileAction.open.title, "Open")
        XCTAssertEqual(FileAction.open.systemImage, "folder")
        
        XCTAssertEqual(FileAction.zip.title, "Create Zip")
        XCTAssertEqual(FileAction.zip.systemImage, "doc.zipper")
        
        XCTAssertEqual(FileAction.extract.title, "Extract")
        XCTAssertEqual(FileAction.extract.systemImage, "arrow.down.circle")
        
        XCTAssertEqual(FileAction.preview.title, "Preview")
        XCTAssertEqual(FileAction.preview.systemImage, "eye")
        
        XCTAssertEqual(FileAction.showInFinder.title, "Show in Finder")
        XCTAssertEqual(FileAction.showInFinder.systemImage, "magnifyingglass")
    }
}