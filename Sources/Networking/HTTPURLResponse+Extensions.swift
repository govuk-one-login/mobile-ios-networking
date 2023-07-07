import Foundation

/// HTTPURLResponse
///
/// Extension on `HTTPURLResponse` that adds a computed property `isSuccessful` for response codes in the range `200..<300`
///
/// This is used when handling the HTTP response in the ``NetworkClient`` `makeRequest` method.
extension HTTPURLResponse {
    var isSuccessful: Bool {
        (200..<300).contains(statusCode)
    }
}
