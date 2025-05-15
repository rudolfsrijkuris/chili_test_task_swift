import Foundation

enum Configuration {
    enum Error: Swift.Error {
        case missingKey, invalidValue, emptyValue
        
        var localizedDescription: String {
            switch self {
            case .missingKey:
                return "Configuration key not found"
            case .invalidValue:
                return "Invalid configuration value"
            case .emptyValue:
                return "Empty configuration value"
            }
        }
    }

    private static func extractEnvironmentKey(_ string: String) -> String? {
        if string.hasPrefix("$(") && string.hasSuffix(")") {
            return String(string.dropFirst(2).dropLast(1))
        }
        if string.hasPrefix("${") && string.hasSuffix("}") {
            return String(string.dropFirst(2).dropLast(1))
        }
        return nil
    }

    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        // First try Info.plist
        if let object = Bundle.main.object(forInfoDictionaryKey: key) {
            switch object {
            case let value as T:
                if let strValue = value as? String, strValue.isEmpty {
                    throw Error.emptyValue
                }
                return value
            case let string as String:
                if string.isEmpty {
                    throw Error.emptyValue
                }
                
                if let envKey = extractEnvironmentKey(string) {
                    // First try ProcessInfo environment
                    if let envValue = ProcessInfo.processInfo.environment[envKey] {
                        if envValue.isEmpty {
                            throw Error.emptyValue
                        }
                        guard let value = T(envValue) else {
                            throw Error.invalidValue
                        }
                        return value
                    }
                    
                    // Then try Info.plist again with the key
                    if let envValue = Bundle.main.object(forInfoDictionaryKey: envKey) as? String {
                        if envValue.isEmpty {
                            throw Error.emptyValue
                        }
                        guard let value = T(envValue) else {
                            throw Error.invalidValue
                        }
                        return value
                    }
                    
                    throw Error.missingKey
                }
                
                guard let value = T(string) else {
                    throw Error.invalidValue
                }
                return value
            default:
                throw Error.invalidValue
            }
        }
        
        // Try environment variables
        if let envValue = ProcessInfo.processInfo.environment[key] {
            if envValue.isEmpty {
                throw Error.emptyValue
            }
            guard let value = T(envValue) else {
                throw Error.invalidValue
            }
            return value
        }
        
        throw Error.missingKey
    }
}

extension Configuration {
    static var giphyApiKey: String {
        do {
            return try Configuration.value(for: "GIPHY_API_KEY")
        } catch {
            fatalError("Missing Giphy API key. Please set up your API key in Config.xcconfig")
        }
    }
} 