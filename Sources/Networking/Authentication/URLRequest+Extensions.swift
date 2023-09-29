import Foundation

extension URLRequest {
    func authorized(with token: String) -> Self {
        var request = self
        request.addValue("Bearer \(token)",
                         forHTTPHeaderField: "Authorization")
        return request
    }
}
