import Foundation

/// Extension on HTTPURLResponse
///
/// This is for mocking purposes and could be set to any well-known and reliable url.
public extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.google.com"
        let url = components.url!
        self.init(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
