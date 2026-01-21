import Foundation

/// ServerError
///
/// Conforms to ``ErrorWithCode`` and adds additional `reason` property as well as a computed `parameters` property.
/// This consolidates the various properties and nil-coalesces them to remove optionality into a dictionary.
public struct ServerError: ErrorWithCode {
    public let reason: String?
    public let endpoint: String?
    public let errorCode: Int
    public let response: Data?
    
    public init(reason: String? = "server", endpoint: String?, errorCode: Int, response: Data? = nil) {
        self.reason = reason
        self.endpoint = endpoint
        self.errorCode = errorCode
        self.response = response
    }
}

extension ServerError: CustomNSError {}
