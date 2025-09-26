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
        SafeParsers.encodeJSON(data)
    }

    public static func decode<T: Codable>(_ jsonString: String?, as type: T.Type) -> T? {
        SafeParsers.parseJSON(jsonString, as: type)
    }

    public static func encodeTargets(_ targets: [String]) -> String {
        SafeParsers.encodeStringArray(targets)
    }

    public static func decodeTargets(_ jsonString: String) -> [String] {
        SafeParsers.parseStringArray(jsonString)
    }
}
