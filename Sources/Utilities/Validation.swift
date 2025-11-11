import Foundation

struct Validation {
    static func isValidPath(_ path: String) -> Bool {
        // Basic path validation - check for dangerous characters and patterns
        let invalidPatterns = Constants.Validation.dangerousPathPatterns
        
        for pattern in invalidPatterns {
            if path.contains(pattern) {
                return false
            }
        }
        
        // Check for absolute path requirement in some contexts
        return !path.isEmpty && path.count <= Constants.Validation.maxPathLength // Reasonable path length limit
    }
    
    static func isValidArchiveName(_ name: String) -> Bool {
        // Archive names should be reasonable filenames
        guard !name.isEmpty && name.count <= Constants.Validation.maxArchiveNameLength else { return false }
        
        // Check for valid filename characters (basic check)
        let invalidChars = Constants.Validation.invalidFilenameChars
        return name.rangeOfCharacter(from: invalidChars) == nil
    }
    
    static func sanitizePath(_ path: String) -> String {
        // Basic sanitization - remove dangerous characters
        return path
            .replacingOccurrences(of: "\0", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    static func validateDestinationDirectory(_ path: String) -> Result<String, ZippyError> {
        let sanitizedPath = sanitizePath(path)
        
        guard isValidPath(sanitizedPath) else {
            return .failure(.invalidPath(path: sanitizedPath))
        }
        
        // Check if parent directory exists and is writable
        let url = URL(fileURLWithPath: sanitizedPath)
        let parentURL = url.deletingLastPathComponent()
        
        do {
            let parentAttributes = try FileManager.default.attributesOfItem(atPath: parentURL.path)
            guard let parentType = parentAttributes[.type] as? FileAttributeType,
                  parentType == .typeDirectory else {
                return .failure(.directoryNotFound(path: parentURL.path))
            }
            
            // Check write permissions
            guard (parentAttributes[.posixPermissions] as? UInt16 ?? 0) & 0o200 != 0 else {
                return .failure(.permissionDenied(path: parentURL.path))
            }
            
        } catch {
            return .failure(.directoryNotFound(path: parentURL.path))
        }
        
        return .success(sanitizedPath)
    }
}