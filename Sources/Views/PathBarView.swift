import SwiftUI

struct PathBarView: View {
    @Binding var currentPath: String
    let onNavigate: (String) -> Void
    let onBreadcrumbClick: (Int) -> Void
    
    @State private var editablePath: String = ""
    @State private var isEditingPath = false
    
    var pathComponents: [String] {
        let components = (currentPath as NSString).pathComponents
        return components.filter { $0 != "/" }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Editable path bar with Go button
            HStack(spacing: 8) {
                TextField("Path", text: $editablePath)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                    .onSubmit {
                        navigateToPath()
                    }
                    .onAppear {
                        editablePath = currentPath
                    }
                    .onChange(of: currentPath) { newValue in
                        if !isEditingPath {
                            editablePath = newValue
                        }
                    }
                    .onChange(of: editablePath) { _ in
                        isEditingPath = true
                    }
                
                Button(action: navigateToPath) {
                    Text("Go")
                        .frame(minWidth: 50)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            
            // Breadcrumb navigation
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    // Root
                    Button(action: {
                        onBreadcrumbClick(-1)
                    }) {
                        Image(systemName: "house.fill")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                    
                    if !pathComponents.isEmpty {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Path components
                    ForEach(Array(pathComponents.enumerated()), id: \.offset) { index, component in
                        Button(action: {
                            onBreadcrumbClick(index)
                        }) {
                            Text(component)
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                        
                        if index < pathComponents.count - 1 {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func navigateToPath() {
        isEditingPath = false
        let trimmedPath = editablePath.trimmingCharacters(in: .whitespaces)
        if !trimmedPath.isEmpty {
            onNavigate(trimmedPath)
        }
    }
}
