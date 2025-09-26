import Foundation

// MARK: - JSON Serializer
public struct JSONSerializer {
    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    public static func encode<T: Codable>(_ data: T?) -> String? {
        guard let data = data else {
            return nil
        }

        do {
            let jsonData = try encoder.encode(data)
            return String(bytes: jsonData, encoding: .utf8) ?? ""
        } catch {
            return nil
        }
    }

    public static func decode<T: Codable>(_ jsonString: String?, as type: T.Type) -> T? {
        guard let jsonString = jsonString,
              let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }

        do {
            return try decoder.decode(type, from: jsonData)
        } catch {
            return nil
        }
    }

    public static func encodeTargets(_ targets: [String]) -> String {
        do {
            let jsonData = try encoder.encode(targets)
            return String(bytes: jsonData, encoding: .utf8) ?? "[]"
        } catch {
            return "[]"
        }
    }

    public static func decodeTargets(_ jsonString: String) -> [String] {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return []
        }

        do {
            return try decoder.decode([String].self, from: jsonData)
        } catch {
            return []
        }
    }
}
