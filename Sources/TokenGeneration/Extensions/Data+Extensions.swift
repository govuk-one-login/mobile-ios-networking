import Foundation.NSData

extension Data {
    /// Base 64 encoding the string.
    ///
    /// Removing unallowed URL encoded character:
    ///   - "="
    ///
    /// Replacing unallowed URL encoded characters:
    ///   - "+" with "-"
    ///   - "/" with "_"
    var base64URLEncodedString: String {
        base64EncodedString()
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
    }
}
