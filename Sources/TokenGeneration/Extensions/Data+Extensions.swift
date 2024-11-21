import Foundation.NSData

extension Data {
    /// Base 64 encoding the string.
    /// Description of this format: https://datatracker.ietf.org/doc/html/rfc4648#section-5
    ///
    /// Removing unsupported URL encoded character:
    ///   - "="
    ///
    /// Replacing unsupported URL encoded characters:
    ///   - "+" with "-"
    ///   - "/" with "_"
    var base64URLEncodedString: String {
        base64EncodedString()
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
    }
}
