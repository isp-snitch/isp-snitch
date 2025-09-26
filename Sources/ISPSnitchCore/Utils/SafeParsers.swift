import Foundation

// MARK: - Safe Parsers
/// Clean Swift parsers that eliminate force unwrapping
public struct SafeParsers {

    // MARK: - UUID Parsing (Safe)
    public static func parseUUID(from string: String) -> UUID? {
        UUID(uuidString: string)
    }

    public static func parseUUID(from string: String?) -> UUID? {
        guard let string = string else {
            return nil
        }
        return UUID(uuidString: string)
    }

    // MARK: - JSON Parsing (Safe)
    public static func parseJSON<T: Codable>(_ jsonString: String?, as type: T.Type) -> T? {
        guard let jsonString = jsonString,
              let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(type, from: jsonData)
        } catch {
            return nil
        }
    }

    public static func encodeJSON<T: Codable>(_ data: T?) -> String? {
        guard let data = data else {
            return nil
        }

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let jsonData = try encoder.encode(data)
            return String(bytes: jsonData, encoding: .utf8) ?? ""
        } catch {
            return nil
        }
    }

    // MARK: - String Array Parsing (Safe)
    public static func parseStringArray(_ jsonString: String) -> [String] {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return []
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode([String].self, from: jsonData)
        } catch {
            return []
        }
    }

    public static func encodeStringArray(_ array: [String]) -> String {
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(array)
            return String(bytes: jsonData, encoding: .utf8) ?? ""
        } catch {
            return "[]"
        }
    }
}

// MARK: - Parse Error
public enum ParseError: Error, Sendable {
    case invalidUUID(String)
    case jsonDecodeError(Error)
    case jsonEncodeError(String)
    case invalidData(String)
    case regexError(String)

    public var localizedDescription: String {
        switch self {
        case .invalidUUID(let string):
            return "Invalid UUID string: \(string)"
        case .jsonDecodeError(let error):
            return "JSON decode error: \(error.localizedDescription)"
        case .jsonEncodeError(let message):
            return "JSON encode error: \(message)"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        case .regexError(let message):
            return "Regex error: \(message)"
        }
    }
}
