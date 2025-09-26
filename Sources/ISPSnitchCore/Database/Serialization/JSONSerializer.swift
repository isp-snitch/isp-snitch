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
    
    public static func encode<T: Codable>(_ data: T?) throws -> String? {
        guard let data = data else { return nil }
        return try String(data: encoder.encode(data), encoding: .utf8)
    }
    
    public static func decode<T: Codable>(_ jsonString: String?, as type: T.Type) throws -> T? {
        guard let jsonString = jsonString,
              let jsonData = jsonString.data(using: .utf8) else { return nil }
        return try decoder.decode(type, from: jsonData)
    }
    
    public static func encodeTargets(_ targets: [String]) throws -> String {
        return try String(data: encoder.encode(targets), encoding: .utf8)!
    }
    
    public static func decodeTargets(_ jsonString: String) throws -> [String] {
        return try decoder.decode([String].self, from: jsonString.data(using: .utf8)!)
    }
}
