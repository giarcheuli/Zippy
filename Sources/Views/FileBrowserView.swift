import SwiftUI

struct FileBrowserView: View {
    @ObservedObject var fileSystemManager: FileSystemManager
    @Binding var selectedItems: Set<FileItem>
    let onFileDoubleClick: (FileItem) -> Void
    let onExtractZip: (FileItem) -> Void
    let onCreateZip: (FileItem, URL) -> Void
    
    @State private var pathInput = ""
    @State private var showZipConfirmation = false
    @State private var itemToZip: FileItem?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                // Back button
                Button(action: { fileSystemManager.goBack() }) {
                    Image(systemName: "chevron.left")
                }
                .disabled(!fileSystemManager.canGoBack)
                
                // Forward button
                Button(action: { fileSystemManager.goForward() }) {
                    Image(systemName: "chevron.right")
                }
                .disabled(!fileSystemManager.canGoForward)
                
                // Up button
                Button(action: { fileSystemManager.goUp() }) {
                    Image(systemName: "chevron.up")
                }
                .disabled(!fileSystemManager.canGoUp)
                
                Spacer()
            }
            .padding(8)
            
            Divider()
            
            // Path bar
            PathBarView(
                currentPath: $pathInput,
                onNavigate: { path in
                    fileSystemManager.navigateTo(path)
                },
                onBreadcrumbClick: { index in
                    let components = fileSystemManager.pathComponents()
                    if index == -1 {
                        // Root clicked
                        fileSystemManager.navigateTo("/")
                    } else if index < components.count {
                        // Build path up to clicked component
                        let targetComponents = components.prefix(index + 1)
                        let targetPath = "/" + targetComponents.joined(separator: "/")
                        fileSystemManager.navigateTo(targetPath)
                    }
                }
            )
            
            Divider()
            
            // File list
            List(fileSystemManager.files, id: \.self, selection: $selectedItems) { file in
                FileRowView(
                    file: file,
                    isSelected: selectedItems.contains(file),
                    isMultiSelect: selectedItems.count > 1,
                    dateFormatter: dateFormatter,
                    onOpenFolder: {
                        fileSystemManager.openFolder(file.path)
                    },
                    onZipItem: {
                        zipItem(file)
                    },
                    onExtractZip: {
                        onExtractZip(file)
                    },
                    onShowInFinder: {
                        showInFinder(file)
                    }
                )
                .tag(file)
                .onDoubleClick {
                    if file.isDirectory {
                        fileSystemManager.openFolder(file.path)
                    } else if file.isZipFile {
                        onFileDoubleClick(file)
                    }
                }
                .contextMenu {
                    if file.isDirectory {
                        Button(action: { fileSystemManager.openFolder(file.path) }) {
                            Label("Open", systemImage: "folder")
                        }
                        Button(action: { zipItem(file) }) {
                            Label("Create Zip Archive", systemImage: "doc.zipper")
                        }
                        Divider()
                        Button(action: { showInFinder(file) }) {
                            Label("Show in Finder", systemImage: "magnifyingglass")
                        }
                    } else if file.isZipFile {
                        Button(action: { onFileDoubleClick(file) }) {
                            Label("Preview Contents", systemImage: "eye")
                        }
                        Button(action: { onExtractZip(file) }) {
                            Label("Extract Here", systemImage: "arrow.down.circle")
                        }
                        Divider()
                        Button(action: { showInFinder(file) }) {
                            Label("Show in Finder", systemImage: "magnifyingglass")
                        }
                    } else {
                        Button(action: { zipItem(file) }) {
                            Label("Create Zip Archive", systemImage: "doc.zipper")
                        }
                        Divider()
                        Button(action: { showInFinder(file) }) {
                            Label("Show in Finder", systemImage: "magnifyingglass")
                        }
                    }
                }
            }
            .listStyle(.inset)
            .onDrop(of: [.fileURL], isTargeted: nil) { providers, location in
                handleFileDrop(providers: providers)
            }
        }
        .onAppear {
            pathInput = fileSystemManager.currentPath
        }
        .onChange(of: fileSystemManager.currentPath) { newPath in
            pathInput = newPath
        }
        .alert(Constants.Messages.createZipConfirmation, isPresented: $showZipConfirmation) {
            Button("Cancel", role: .cancel) {
                itemToZip = nil
            }
            Button("Create Zip") {
                if let item = itemToZip {
                    createZipFromItem(item)
                    itemToZip = nil
                }
            }
        } message: {
            if let item = itemToZip {
                Text("Create zip archive of '\(item.name)'?")
            }
        }
        .background(
            // Invisible buttons for keyboard shortcuts
            Group {
                Button("") { fileSystemManager.goUp() }
                    .keyboardShortcut(.upArrow, modifiers: [.command])
                    .opacity(0)
                
                Button("") { fileSystemManager.goBack() }
                    .keyboardShortcut(.leftArrow, modifiers: [.command])
                    .opacity(0)
                
                Button("") { fileSystemManager.goForward() }
                    .keyboardShortcut(.rightArrow, modifiers: [.command])
                    .opacity(0)
                
                Button("") { fileSystemManager.refresh() }
                    .keyboardShortcut("r", modifiers: [.command])
                    .opacity(0)
                
                Button("") { 
                    if let selectedFile = selectedItems.first, selectedFile.isZipFile {
                        onFileDoubleClick(selectedFile)
                    }
                }
                .keyboardShortcut(.space)
                .opacity(0)
                
                Button("") {
                    if let selectedFile = selectedItems.first {
                        zipItem(selectedFile)
                    }
                }
                .keyboardShortcut("n", modifiers: [.command])
                .opacity(0)
                
                Button("") {
                    if let selectedFile = selectedItems.first, selectedFile.isZipFile {
                        onExtractZip(selectedFile)
                    }
                }
                .keyboardShortcut("e", modifiers: [.command])
                .opacity(0)
            }
        )
    }
    
    private func zipItem(_ file: FileItem) {
        itemToZip = file
        showZipConfirmation = true
    }
    
    private func createZipFromItem(_ item: FileItem) {
        // Show save panel for destination
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.zip]
        savePanel.nameFieldStringValue = "\(item.name).zip"
        savePanel.message = "Save ZIP archive as"
        savePanel.directoryURL = URL(fileURLWithPath: fileSystemManager.currentPath)
        
        savePanel.begin { response in
            if response == .OK, let destinationURL = savePanel.url {
                onCreateZip(item, destinationURL)
            }
        }
    }
    
    private func showInFinder(_ file: FileItem) {
        NSWorkspace.shared.selectFile(file.path, inFileViewerRootedAtPath: "")
    }
    
    private func handleFileDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (item, error) in
                if let data = item as? Data,
                   let url = URL(dataRepresentation: data, relativeTo: nil) {
                    DispatchQueue.main.async {
                        processDroppedFile(url: url)
                    }
                }
            }
        }
        return true
    }
    
    private func processDroppedFile(url: URL) {
        // Check if it's a zip file
        if url.pathExtension.lowercased() == Constants.FileExtensions.zip {
            // Extract the dropped zip file
            onExtractZip(FileItem(
                name: url.lastPathComponent,
                path: url.path,
                size: 0, // We don't know the size yet
                dateModified: Date(),
                isDirectory: false,
                isZipFile: true
            ))
        } else {
            // Create zip archive from the dropped file/directory
            onCreateZip(FileItem(
                name: url.lastPathComponent,
                path: url.path,
                size: 0, // We don't know the size yet
                dateModified: Date(),
                isDirectory: url.hasDirectoryPath,
                isZipFile: false
            ), URL(fileURLWithPath: fileSystemManager.currentPath).appendingPathComponent("\(url.lastPathComponent).zip"))
        }
    }
}

// MARK: - FileRowView
struct FileRowView: View {
    let file: FileItem
    let isSelected: Bool
    let isMultiSelect: Bool
    let dateFormatter: DateFormatter
    let onOpenFolder: () -> Void
    let onZipItem: () -> Void
    let onExtractZip: () -> Void
    let onShowInFinder: () -> Void
    
    private var fileActions: FileActions {
        FileActions(file: file, isMultiSelect: isMultiSelect)
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: file.icon)
                .foregroundColor(file.isDirectory ? .blue : (file.isZipFile ? .orange : .secondary))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(file.name)
                    .font(.body)
                
                HStack(spacing: 12) {
                    Text(file.sizeFormatted)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(dateFormatter.string(from: file.dateModified))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Show action buttons when selected (disabled for multi-select)
            if isSelected && !isMultiSelect {
                HStack(spacing: 8) {
                    ForEach(fileActions.availableActions, id: \.self) { action in
                        Button(action: {
                            performAction(action)
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: action.systemImage)
                                    .font(.caption)
                                Text(action.title)
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func performAction(_ action: FileAction) {
        switch action {
        case .open:
            onOpenFolder()
        case .zip:
            onZipItem()
        case .extract:
            onExtractZip()
        case .showInFinder:
            onShowInFinder()
        }
    }
}

// MARK: - View Extension
extension View {
    func onDoubleClick(perform action: @escaping () -> Void) -> some View {
        self.onTapGesture(count: 2) {
            action()
        }
    }
}
