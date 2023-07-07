import CryptoKit
import Foundation

/// ErrorWithCode
///
/// An error type for storing and logging API errors for to help with problem tracking, defect resolution and identification.
///
/// The `hash` property is calculated by a method in protocol extension that returns and stores a hash from the `errorCode` and `endpoint` properties.
///
/// This hash uses a deterministic hashing algorithm, can be relied on the output hash being the same for consistent input values.
/// This makes the `hash` property useful for error tracking and reporting via logging or analytics.
///
/// Used by ``ServerError``
public protocol ErrorWithCode: Error {
    var hash: String? { get }
    var errorCode: Int { get }
    var endpoint: String? { get }
}

extension ErrorWithCode {
    public var hash: String? {
        guard let endpoint else { return nil }
        let string = "\(errorCode)_\(endpoint)"
        let digest = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())
        
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}
