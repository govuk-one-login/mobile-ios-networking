import Foundation

extension URLRequest {
    func tokenExchange(subjectToken: String, scope: String) -> Self {
        var request = self
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        var urlParser = URLComponents()
        urlParser.queryItems = [
            URLQueryItem(name: "grant-type", value: "urn:ietf:params:oauth:grant-type:token-exchange"),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "subject-token", value: subjectToken),
            URLQueryItem(name: "subject-token-type", value: "urn:ietf:params:oauth:token-type:access_token")
        ]
        request.httpBody = urlParser.percentEncodedQuery?.data(using: .utf8)
        return request
    }
    
    func authorized(with token: String) -> Self {
        var request = self
        request.addValue("Bearer \(token)",
                         forHTTPHeaderField: "Authorization")
        return request
    }
}
