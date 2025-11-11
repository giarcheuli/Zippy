import Foundation

enum ZipItem: Identifiable {
    case file(name: String, size: Int64, path: String)
    case directory(name: String, path: String)
    
    var id: String {
        switch self {
        case .file(_, _, let path), .directory(_, let path):
            return path
        }
    }
    
    var name: String {
        switch self {
        case .file(let name, _, _), .directory(let name, _):
            return name
        }
    }
    
    var isDirectory: Bool {
        if case .directory = self {
            return true
        }
        return false
    }
    
    var sizeFormatted: String {
        if case .file(_, let size, _) = self {
            return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
        }
        return "--"
    }
}
