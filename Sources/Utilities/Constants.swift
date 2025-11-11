import Foundation

struct Constants {
    // File extensions
    struct FileExtensions {
        static let zip = "zip"
        static let allArchives = ["zip"]
    }
    
    // UI Constants
    struct UI {
        static let defaultWindowWidth: CGFloat = 1000
        static let defaultWindowHeight: CGFloat = 700
        static let minWindowWidth: CGFloat = 800
        static let minWindowHeight: CGFloat = 600
        
        static let loadingOverlayCornerRadius: CGFloat = 12
        static let loadingOverlayShadowRadius: CGFloat = 8
        
        static let extractDialogWidth: CGFloat = 500
    }
    
    // File system constants
    struct FileSystem {
        static let maxPathLength = 1024
        static let refreshDebounceInterval: TimeInterval = 0.5
        
        // Common directories
        static let downloadsDirectory = "~/Downloads"
        static let desktopDirectory = "~/Desktop"
        static let documentsDirectory = "~/Documents"
    }
    
    // Zip operations
    struct ZipOperations {
        static let compressionMethod = "none" // Using string for now, could be enum later
        static let defaultArchiveExtension = "zip"
        static let maxArchiveNameLength = 255
    }
    
    // Error messages and user-facing strings
    struct Messages {
        static let processing = "Processing..."
        static let extracting = "Extracting archive..."
        static let creating = "Creating archive..."
        static let loadingContents = "Loading archive contents..."
        
        static let extractionMayTakeTime = "This may take a few moments"
        static let largeArchiveWarning = "This may take a moment for large archives"
        
        static let noZipSelected = "No zip selected"
        static let selectZipInstruction = "Select a zip file from the file browser above"
        
        static let emptyArchive = "Empty archive"
        
        static let createZipConfirmation = "Create Zip Archive"
        static let extractArchive = "Extract Archive"
    }
    
    // Keyboard shortcuts
    struct KeyboardShortcuts {
        static let goUp: String = "upArrow+command"
        static let goBack: String = "leftArrow+command"
        static let goForward: String = "rightArrow+command"
        static let refresh: String = "r+command"
        static let openPath: String = "o+command"
        static let preview: String = "space"
        static let createZip: String = "n+command"
        static let extract: String = "e+command"
        static let globalRefresh: String = "r+command+shift"
        static let globalExtract: String = "e+command+shift"
    }
    
    // Validation constants
    struct Validation {
        static let maxPathLength = 1024
        static let maxArchiveNameLength = 255
        static let dangerousPathPatterns = ["..", "~", "\0", "\n", "\r"]
        static let invalidFilenameChars = CharacterSet(charactersIn: "/\\:*?\"<>|")
    }
    
    // Logging
    struct Logging {
        static let subsystem = "com.zippy.app"
        static let category = "ZipOperations"
    }
    
    // Date formatting
    struct DateFormats {
        static let fileListFormat = "short+short"
        static let archiveInfoFormat = "medium+short"
    }
}