import SwiftUI

struct ExtractDialogView: View {
    let zipFileName: String
    let defaultDestination: String
    let onExtract: (String) -> Void
    let onCancel: () -> Void
    
    @State private var destinationPath: String
    @State private var isExtracting = false
    
    init(zipFileName: String, defaultDestination: String, onExtract: @escaping (String) -> Void, onCancel: @escaping () -> Void) {
        self.zipFileName = zipFileName
        self.defaultDestination = defaultDestination
        self.onExtract = onExtract
        self.onCancel = onCancel
        self._destinationPath = State(initialValue: defaultDestination)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Title
            HStack {
                Image(systemName: "doc.zipper")
                    .font(.largeTitle)
                    .foregroundColor(.orange)
                Text(Constants.Messages.extractArchive)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            // Zip file name
            VStack(alignment: .leading, spacing: 4) {
                Text("Archive:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(zipFileName)
                    .font(.body)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            if isExtracting {
                // Loading state during extraction
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    
                    Text(Constants.Messages.extracting)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(Constants.Messages.extractionMayTakeTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(height: 120)
            } else {
                // Destination path input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Extract to:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        TextField("Destination path", text: $destinationPath)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                            .disabled(isExtracting)
                        
                        Button(action: choosePath) {
                            Image(systemName: "folder")
                        }
                        .disabled(isExtracting)
                    }
                }
            }
            
            // Buttons
            HStack(spacing: 12) {
                Button("Cancel") {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)
                .disabled(isExtracting)
                
                Spacer()
                
                Button(isExtracting ? "Extracting..." : "Extract Here") {
                    startExtraction()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(isExtracting || destinationPath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(24)
        .frame(width: Constants.UI.extractDialogWidth)
    }
    
    private func choosePath() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.message = "Choose extraction destination"
        panel.prompt = "Select"
        
        // Set initial directory
        let currentURL = URL(fileURLWithPath: destinationPath)
        if FileManager.default.fileExists(atPath: currentURL.path) {
            panel.directoryURL = currentURL
        }
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                destinationPath = url.path
            }
        }
    }
    
    private func startExtraction() {
        isExtracting = true
        onExtract(destinationPath)
    }
}
