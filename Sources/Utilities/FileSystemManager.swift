import Foundation

class FileSystemManager: ObservableObject {
    @Published var currentPath: String
    @Published var files: [FileItem] = []
    @Published var isLoading = false
    @Published var error: ZippyError?
    
    private var backHistory: [String] = []
    private var forwardHistory: [String] = []
    
    init(initialPath: String = "~/Desktop") {
        self.currentPath = Self.resolvePath(initialPath)
        loadFiles()
    }
    
    var canGoBack: Bool {
        !backHistory.isEmpty
    }
    
    var canGoForward: Bool {
        !forwardHistory.isEmpty
    }
    
    var canGoUp: Bool {
        currentPath != "/"
    }
    
    // MARK: - Path Resolution
    
    static func resolvePath(_ path: String) -> String {
        let expandedPath = NSString(string: path).expandingTildeInPath
        return (expandedPath as NSString).standardizingPath
    }
    
    func pathComponents() -> [String] {
        let components = (currentPath as NSString).pathComponents
        return components.filter { $0 != "/" }
    }
    
    func pathUpToComponent(at index: Int) -> String {
        let components = pathComponents()
        let selectedComponents = Array(components.prefix(index + 1))
        return "/" + selectedComponents.joined(separator: "/")
    }
    
    // MARK: - Navigation
    
    func navigateTo(_ path: String) {
        let resolvedPath = Self.resolvePath(path)
        
        // Verify path exists and is a directory
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: resolvedPath, isDirectory: &isDir),
              isDir.boolValue else {
            error = .invalidPath(path: resolvedPath)
            return
        }
        
        // Add current path to back history
        if currentPath != resolvedPath {
            backHistory.append(currentPath)
            forwardHistory.removeAll()
        }
        
        currentPath = resolvedPath
        loadFiles()
    }
    
    func goBack() {
        guard let previousPath = backHistory.popLast() else { return }
        forwardHistory.append(currentPath)
        currentPath = previousPath
        loadFiles()
    }
    
    func goForward() {
        guard let nextPath = forwardHistory.popLast() else { return }
        backHistory.append(currentPath)
        currentPath = nextPath
        loadFiles()
    }
    
    func goUp() {
        let parentPath = (currentPath as NSString).deletingLastPathComponent
        guard parentPath != currentPath else { return }
        navigateTo(parentPath)
    }
    
    func openFolder(_ folderPath: String) {
        navigateTo(folderPath)
    }
    
    // MARK: - File Loading
    
    func loadFiles() {
        isLoading = true
        error = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                let fileManager = FileManager.default
                let contents = try fileManager.contentsOfDirectory(atPath: self.currentPath)
                
                var fileItems: [FileItem] = []
                
                for filename in contents {
                    // Skip hidden files
                    if filename.hasPrefix(".") { continue }
                    
                    let fullPath = (self.currentPath as NSString).appendingPathComponent(filename)
                    
                    var isDir: ObjCBool = false
                    guard fileManager.fileExists(atPath: fullPath, isDirectory: &isDir) else {
                        continue
                    }
                    
                    let attributes = try fileManager.attributesOfItem(atPath: fullPath)
                    let size = attributes[.size] as? Int64 ?? 0
                    let dateModified = attributes[.modificationDate] as? Date ?? Date()
                    
                    let isDirectory = isDir.boolValue
                    let isZipFile = !isDirectory && (filename as NSString).pathExtension.lowercased() == "zip"
                    
                    let fileItem = FileItem(
                        name: filename,
                        path: fullPath,
                        size: size,
                        dateModified: dateModified,
                        isDirectory: isDirectory,
                        isZipFile: isZipFile
                    )
                    
                    fileItems.append(fileItem)
                }
                
                // Sort: directories first, then by name
                fileItems.sort { item1, item2 in
                    if item1.isDirectory != item2.isDirectory {
                        return item1.isDirectory
                    }
                    return item1.name.localizedCaseInsensitiveCompare(item2.name) == .orderedAscending
                }
                
                DispatchQueue.main.async {
                    self.files = fileItems
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = .unknown(reason: "Failed to load files: \(error.localizedDescription)")
                    self.files = []
                    self.isLoading = false
                }
            }
        }
    }
    
    func refresh() {
        loadFiles()
    }
}
