import Foundation

struct FileItem: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    let path: String
    let size: Int64
    let dateModified: Date
    let isDirectory: Bool
    let isZipFile: Bool
    
    var sizeFormatted: String {
        if isDirectory {
            return "--"
        }
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
    
    var icon: String {
        if isDirectory {
            return "folder.fill"
        } else if isZipFile {
            return "doc.zipper"
        } else {
            return "doc.fill"
        }
    }
    
    var url: URL {
        URL(fileURLWithPath: path)
    }
    
    static func == (lhs: FileItem, rhs: FileItem) -> Bool {
        lhs.path == rhs.path
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
}
