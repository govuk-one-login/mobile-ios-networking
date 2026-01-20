import Foundation

/// ServerError
///
/// Conforms to ``ErrorWithCode`` and adds additional `reason` property as well as a computed `parameters` property.
/// This consolidates the various properties and nil-coalesces them to remove optionality into a dictionary.
public struct ServerError: ErrorWithCode {
    public let reason: String? = "server"
    public let endpoint: String?
    public let errorCode: Int
    public var grantType: GrantType? = .unknown
}

struct ErrorResponse: Decodable {
    let error: GrantType?
    let errorDescription: String?
    
    enum CodingKeys: String, CodingKey {
        case error
        case errorDescription = "error_description"
    }
}

public enum GrantType: String, Decodable {
    case invalidGrant = "invalid_grant"
    case invalidTarget = "invalid_target"
    case unknown
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        self = GrantType(rawValue: rawValue) ?? .unknown
    }
}

extension ServerError: CustomNSError {}
