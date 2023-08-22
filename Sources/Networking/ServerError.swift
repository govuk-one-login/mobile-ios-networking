import Foundation

/// ServerError
///
/// Conforms to ``ErrorWithCode`` and adds additional `reason` property as well as a computed `parameters` property.
/// This consolidates the various properties and nil-coalesces them to remove optionality into a dictionary.
public struct ServerError: ErrorWithCode {
    public let reason: String? = "server"
    public let endpoint: String?
    public let errorCode: Int
}
