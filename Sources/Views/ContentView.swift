import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var zipManager = ZipManager()
    @StateObject private var fileSystemManager = FileSystemManager()
    
    @State private var selectedZipURL: URL?
    @State private var selectedItems: Set<FileItem> = []
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showExtractDialog = false
    
    var body: some View {
        ZStack {
            VSplitView {
                // Top Section - File Browser
                FileBrowserView(
                    fileSystemManager: fileSystemManager,
                    selectedItems: $selectedItems,
                    onFileDoubleClick: { file in
                        // Handle double-click on zip files (preview)
                        if file.isZipFile {
                            handleZipSelection(file)
                        }
                    },
                    onExtractZip: { file in
                        // Trigger extract dialog for the selected zip
                        selectedZipURL = file.url
                        showExtractDialog = true
                    },
                    onCreateZip: { item, destinationURL in
                        createZipFromItem(item, to: destinationURL)
                    }
                )
                
                // Bottom Section - Zip Content Viewer
                VStack(spacing: 0) {
                    Divider()
                    
                    ZipContentView(
                        zipManager: zipManager,
                        selectedZipURL: selectedZipURL
                    )
                }
            }
            .frame(minWidth: Constants.UI.minWindowWidth, idealWidth: Constants.UI.defaultWindowWidth, maxWidth: .infinity,
                   minHeight: Constants.UI.minWindowHeight, idealHeight: Constants.UI.defaultWindowHeight, maxHeight: .infinity)
            .disabled(zipManager.isProcessing)
            
            // Loading overlay
            if zipManager.isProcessing {
                Color.black.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle())
                    
                    Text("Processing...")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let error = zipManager.error {
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .frame(width: 300, height: 150)
                .background(Color(nsColor: .windowBackgroundColor))
                .cornerRadius(Constants.UI.loadingOverlayCornerRadius)
                .shadow(radius: Constants.UI.loadingOverlayShadowRadius)
            }
        }
        .alert("Result", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showExtractDialog) {
            if let zipURL = selectedZipURL {
                let zipName = (zipURL.lastPathComponent as NSString).deletingPathExtension
                let defaultDestination = (fileSystemManager.currentPath as NSString)
                    .appendingPathComponent(zipName)
                
                ExtractDialogView(
                    zipFileName: zipURL.lastPathComponent,
                    defaultDestination: defaultDestination,
                    onExtract: { destination in
                        showExtractDialog = false
                        extractArchive(to: destination)
                    },
                    onCancel: {
                        showExtractDialog = false
                    }
                )
            }
        }
        .background(
            // Global keyboard shortcuts
            Group {
                Button("") { fileSystemManager.refresh() }
                    .keyboardShortcut("r", modifiers: [.command, .shift])
                    .opacity(0)
                
                Button("") {
                    if let selectedFile = selectedItems.first, selectedFile.isZipFile {
                        selectedZipURL = selectedFile.url
                        showExtractDialog = true
                    }
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])
                .opacity(0)
            }
        )
        .onChange(of: selectedItems) { newSelection in
            // Update zip preview when a single zip file is selected
            if newSelection.count == 1, let file = newSelection.first, file.isZipFile {
                handleZipSelection(file)
            } else {
                selectedZipURL = nil
                zipManager.items = []
            }
        }
    }
    
    private func handleZipSelection(_ file: FileItem) {
        Logger.logUIAction("Selected zip file", details: file.name)
        selectedZipURL = file.url
        
        Task {
            do {
                let zipItems = try await zipManager.listContents(of: file.url)
                zipManager.items = zipItems
                Logger.info("Successfully loaded \(zipItems.count) items from \(file.name)")
            } catch {
                if let zippyError = error as? ZippyError {
                    zipManager.error = zippyError
                } else {
                    zipManager.error = .archiveReadFailed(reason: error.localizedDescription)
                }
                Logger.error("Failed to load zip contents for \(file.name): \(error.localizedDescription)")
            }
        }
    }
    
    private func createZipFromItem(_ item: FileItem, to destinationURL: URL) {
        Logger.logUIAction("Creating zip archive", details: "from \(item.name) to \(destinationURL.lastPathComponent)")
        
        Task {
            do {
                try await zipManager.createArchive(from: [item.url], to: destinationURL)
                alertMessage = "Zip archive created successfully!"
                showAlert = true
                fileSystemManager.refresh()
                Logger.logFileOperation("create zip", path: destinationURL.path, success: true)
            } catch {
                if let zippyError = error as? ZippyError {
                    alertMessage = zippyError.localizedDescription
                } else {
                    alertMessage = error.localizedDescription
                }
                showAlert = true
                Logger.logFileOperation("create zip", path: destinationURL.path, success: false, errorMessage: error.localizedDescription)
            }
        }
    }
    
    private func extractArchive(to destinationPath: String) {
        guard let zipURL = selectedZipURL else { return }
        
        Logger.logUIAction("Extracting archive", details: "\(zipURL.lastPathComponent) to \(destinationPath)")
        
        let destinationURL = URL(fileURLWithPath: destinationPath)
        
        Task {
            do {
                try await zipManager.extractArchive(from: zipURL, to: destinationURL)
                alertMessage = "Archive extracted successfully to:\n\(destinationPath)"
                showAlert = true
                fileSystemManager.refresh()
                showExtractDialog = false // Close dialog on success
                Logger.logFileOperation("extract archive", path: destinationPath, success: true)
            } catch {
                if let zippyError = error as? ZippyError {
                    alertMessage = zippyError.localizedDescription
                } else {
                    alertMessage = error.localizedDescription
                }
                showAlert = true
                showExtractDialog = false // Close dialog on failure
                Logger.logFileOperation("extract archive", path: destinationPath, success: false, errorMessage: error.localizedDescription)
            }
        }
    }
}
