import Foundation

struct FileActions {
    let file: FileItem
    let isMultiSelect: Bool
    
    var availableActions: [FileAction] {
        if isMultiSelect {
            return []
        }
        
        switch (file.isDirectory, file.isZipFile) {
        case (true, _): // Directory
            return [.open, .zip, .showInFinder]
        case (false, true): // Zip file
            return [.extract, .showInFinder]
        case (false, false): // Regular file
            return [.zip, .showInFinder]
        }
    }
}

enum FileAction {
    case open, zip, extract, showInFinder
    
    var title: String {
        switch self {
        case .open: return "Open"
        case .zip: return "Zip It"
        case .extract: return "Extract"
        case .showInFinder: return "Show in Finder"
        }
    }
    
    var systemImage: String {
        switch self {
        case .open: return "folder"
        case .zip: return "doc.zipper"
        case .extract: return "arrow.down.doc"
        case .showInFinder: return "eye"
        }
    }
}