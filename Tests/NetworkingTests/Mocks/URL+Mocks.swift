import Foundation

extension URLRequest {
    static var example: URLRequest {
        URLRequest(url: .example)
    }
}

extension URL {
    static var example: URL {
        URL(string: "https://www.example.com")!
    }
}
