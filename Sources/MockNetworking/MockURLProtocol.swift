import Foundation

/// MockURLProtocol
///
/// Used for mocking a url response for unit testing.
public final class MockURLProtocol: URLProtocol {
    public private(set) static var requests: [URLRequest] = []
    public static var handler: (() throws -> (Data, URLResponse))?
    
    public static func clear() {
        requests = []
        handler = nil
    }
    
    public override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    public override static func canInit(with request: URLRequest) -> Bool {
        requests.append(request)
        return true
    }
    
    public override func startLoading() {
        do {
            if let (data, response) = try Self.handler?() {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
            }
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    public override func stopLoading() {
        // This method is unused in the mock currently
    }
}
