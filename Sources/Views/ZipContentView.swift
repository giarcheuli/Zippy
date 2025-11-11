import SwiftUI

struct ZipContentView: View {
    @ObservedObject var zipManager: ZipManager
    let selectedZipURL: URL?
    
    var body: some View {
        VStack(spacing: 0) {
            // Content area
            if zipManager.isProcessing {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle())
                    
                    Text(Constants.Messages.loadingContents)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let url = selectedZipURL {
                        Text("Reading: \(url.lastPathComponent)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    
                    Text(Constants.Messages.largeArchiveWarning)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else if let error = zipManager.error {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    Text(error.localizedDescription)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    if let suggestion = error.recoverySuggestion {
                        Text(suggestion)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else if selectedZipURL == nil {
                VStack(spacing: 16) {
                    Image(systemName: "doc.zipper")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    Text(Constants.Messages.noZipSelected)
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text(Constants.Messages.selectZipInstruction)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if zipManager.items.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.zipper")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    Text(Constants.Messages.emptyArchive)
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 0) {
                    // Contents list
                    List {
                        if let url = selectedZipURL {
                            Section {
                                HStack {
                                    Image(systemName: "doc.zipper")
                                        .foregroundColor(.orange)
                                    Text(url.lastPathComponent)
                                        .font(.headline)
                                }
                            }
                        }
                        
                        Section("Contents (\(zipManager.items.count) items)") {
                            ForEach(zipManager.items) { item in
                                HStack {
                                    Image(systemName: item.isDirectory ? "folder.fill" : "doc.fill")
                                        .foregroundColor(item.isDirectory ? .blue : .secondary)
                                    Text(item.name)
                                    Spacer()
                                    Text(item.sizeFormatted)
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                                .contextMenu {
                                    if item.isDirectory {
                                        // Future: Add extract directory option
                                        Text("Directory: \(item.name)")
                                    } else {
                                        // Future: Add extract file option
                                        Text("File: \(item.name)")
                                    }
                                }
                                .onDrag {
                                    // Allow dragging individual files from zip contents
                                    // For now, just return an empty item provider
                                    // Future: Could implement extracting individual files
                                    NSItemProvider()
                                }
                            }
                        }
                    }
                    .listStyle(.inset)
                    
                    // Statistics bar
                    if let url = selectedZipURL {
                        Divider()
                        
                        HStack(spacing: 24) {
                            // Item count
                            Label("\(zipManager.items.count)", systemImage: "doc.on.doc")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            // Total size
                            Label(totalSize, systemImage: "arrow.down.circle")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            // Modified date
                            if let modifiedDate = fileModificationDate(for: url) {
                                Label(modifiedDate, systemImage: "calendar")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(8)
                        .background(Color(nsColor: .controlBackgroundColor))
                    }
                }
            }
        }
        .background(
            // Keyboard shortcuts for zip content operations
            Group {
                if selectedZipURL != nil {
                    Button("") {
                        // Extract current zip - placeholder for now
                        // This would need an onExtract callback from parent
                    }
                    .keyboardShortcut(.return, modifiers: [.command])
                    .opacity(0)
                }
            }
        )
    }
    
    private var totalSize: String {
        let total = zipManager.items.reduce(Int64(0)) { sum, item in
            if case .file(_, let size, _) = item {
                return sum + size
            }
            return sum
        }
        
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: total)
    }
    
    private func fileModificationDate(for url: URL) -> String? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let modDate = attributes[.modificationDate] as? Date {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                return formatter.string(from: modDate)
            }
        } catch {
            return nil
        }
        return nil
    }
}
