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
        guard let handler = Self.handler else {
            assertionFailure("Remember to set a handler closure when using MockURLProtocol")
            return
        }
        
        do {
            let (data, response) = try handler()
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
            
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    
    public override func stopLoading() {
        // This method is unused in the mock currently
    }
}
