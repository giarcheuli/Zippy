import Foundation
import ZIPFoundation

class ZipManager: ObservableObject {
    @Published var items: [ZipItem] = []
    @Published var isProcessing = false
    @Published var error: ZippyError?
    
    func listContents(of zipURL: URL) async throws -> [ZipItem] {
        Logger.info("Starting to list contents of archive: \(zipURL.lastPathComponent)")
        isProcessing = true
        error = nil
        
        defer {
            isProcessing = false
        }
        
        let startTime = Date()
        
        do {
            let archive = try Archive(url: zipURL, accessMode: .read)
            
            var zipItems: [ZipItem] = []
            
            for entry in archive {
                let name = (entry.path as NSString).lastPathComponent
                
                if entry.type == .directory {
                    zipItems.append(.directory(name: name, path: entry.path))
                } else {
                    zipItems.append(.file(name: name, size: Int64(entry.uncompressedSize), path: entry.path))
                }
            }
            
            let sortedItems = zipItems.sorted { $0.name < $1.name }
            let duration = Date().timeIntervalSince(startTime)
            
            Logger.logPerformance("list archive contents", duration: duration)
            Logger.info("Successfully listed \(sortedItems.count) items from archive: \(zipURL.lastPathComponent)")
            
            return sortedItems
        } catch {
            Logger.logZipOperation("list contents", archivePath: zipURL.lastPathComponent, success: false, errorMessage: error.localizedDescription)
            throw ZippyError.archiveReadFailed(reason: error.localizedDescription)
        }
    }
    
    // Extract zip archive to destination
    func extractArchive(from zipURL: URL, to destinationURL: URL) async throws {
        Logger.info("Starting extraction of archive: \(zipURL.lastPathComponent) to: \(destinationURL.path)")
        isProcessing = true
        error = nil
        
        defer {
            isProcessing = false
        }
        
        let startTime = Date()
        
        do {
            // Validate destination path
            let validationResult = Validation.validateDestinationDirectory(destinationURL.path)
            switch validationResult {
            case .failure(let error):
                Logger.warning("Destination validation failed: \(error.localizedDescription)")
                throw error
            case .success:
                break
            }
            
            let fileManager = FileManager.default
            
            // Create destination directory if needed
            if !fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true)
                Logger.debug("Created destination directory: \(destinationURL.path)")
            }
            
            // Unzip
            try fileManager.unzipItem(at: zipURL, to: destinationURL)
            
            let duration = Date().timeIntervalSince(startTime)
            Logger.logPerformance("extract archive", duration: duration)
            Logger.logZipOperation("extraction", archivePath: zipURL.lastPathComponent, success: true)
        } catch {
            Logger.logZipOperation("extraction", archivePath: zipURL.lastPathComponent, success: false, errorMessage: error.localizedDescription)
            throw error is ZippyError ? error : ZippyError.archiveExtractionFailed(reason: error.localizedDescription)
        }
    }
    
    // Create zip archive from items
    func createArchive(from sourceURLs: [URL], to destinationURL: URL) async throws {
        let sourceNames = sourceURLs.map { $0.lastPathComponent }.joined(separator: ", ")
        Logger.info("Starting creation of archive: \(destinationURL.lastPathComponent) from sources: [\(sourceNames)]")
        isProcessing = true
        error = nil
        
        defer {
            isProcessing = false
        }
        
        let startTime = Date()
        
        do {
            // Validate archive name
            let archiveName = destinationURL.lastPathComponent
            guard Validation.isValidArchiveName(archiveName) else {
                Logger.warning("Invalid archive name: \(archiveName)")
                throw ZippyError.invalidArchiveName(name: archiveName)
            }
            
            // Validate destination directory
            let destinationDir = destinationURL.deletingLastPathComponent().path
            let validationResult = Validation.validateDestinationDirectory(destinationDir)
            switch validationResult {
            case .failure(let error):
                Logger.warning("Destination directory validation failed: \(error.localizedDescription)")
                throw error
            case .success:
                break
            }
            
            let fileManager = FileManager.default
            
            // Remove existing archive if present
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
                Logger.debug("Removed existing archive: \(destinationURL.path)")
            }
            
            // Create archive
            let archive = try Archive(url: destinationURL, accessMode: .create)
            Logger.debug("Created new archive file: \(destinationURL.path)")
            
            // Add items to archive
            for sourceURL in sourceURLs {
                let basePath = sourceURL.lastPathComponent
                
                if sourceURL.hasDirectoryPath {
                    Logger.debug("Adding directory to archive: \(basePath)")
                    // Add directory recursively
                    try await addDirectoryAsync(at: sourceURL, to: archive, basePath: basePath)
                } else {
                    Logger.debug("Adding file to archive: \(basePath)")
                    // Add single file
                    try archive.addEntry(with: basePath, relativeTo: sourceURL.deletingLastPathComponent(), compressionMethod: .none)
                }
            }
            
            let duration = Date().timeIntervalSince(startTime)
            Logger.logPerformance("create archive", duration: duration)
            Logger.logZipOperation("creation", archivePath: destinationURL.lastPathComponent, success: true)
        } catch {
            Logger.logZipOperation("creation", archivePath: destinationURL.lastPathComponent, success: false, errorMessage: error.localizedDescription)
            throw error is ZippyError ? error : ZippyError.archiveCreationFailed(reason: error.localizedDescription)
        }
    }
    
    private func addDirectoryAsync(at url: URL, to archive: Archive, basePath: String) async throws {
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.isDirectoryKey])
        
        while let fileURL = enumerator?.nextObject() as? URL {
            let relativePath = fileURL.path.replacingOccurrences(of: url.path + "/", with: "")
            let archivePath = basePath + "/" + relativePath
            
            var isDirectory: ObjCBool = false
            fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory)
            
            if !isDirectory.boolValue {
                try archive.addEntry(with: archivePath, relativeTo: url.deletingLastPathComponent(), compressionMethod: .none)
            }
        }
    }
    
    private func addDirectory(at url: URL, to archive: Archive, basePath: String) throws {
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.isDirectoryKey])
        
        while let fileURL = enumerator?.nextObject() as? URL {
            let relativePath = fileURL.path.replacingOccurrences(of: url.path + "/", with: "")
            let archivePath = basePath + "/" + relativePath
            
            var isDirectory: ObjCBool = false
            fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory)
            
            if !isDirectory.boolValue {
                try archive.addEntry(with: archivePath, relativeTo: url.deletingLastPathComponent(), compressionMethod: .none)
            }
        }
    }
}
