import Foundation

extension URLRequest {
    func setHeaderValues(_ headerList: [String: String]) -> Self {
        var request = self
        for (key, value) in headerList {
            request.setValue(
                value,
                forHTTPHeaderField: key
            )
        }
        return request
    }
}
