import Foundation

/// MockURLProtocol
///
/// Used for mocking a url response for unit testing.
public final class MockURLProtocol: URLProtocol {
    enum MockURLProtocolError: String, Error {
        case noHandlerSet = "⚠️ Remember to set a handler closure when using MockURLProtocol"
    }
    
    public private(set) static var requests: [URLRequest] = []
    public static var handler: (() throws -> (data: Data, response: URLResponse)) = defaultHandler
    
    static let defaultHandler: (() throws -> (Data, URLResponse)) = {
        assertionFailure(MockURLProtocolError.noHandlerSet.rawValue)
        throw MockURLProtocolError.noHandlerSet
    }
    
    public static func clear() {
        requests = []
        handler = defaultHandler
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
            let handlerResult = try Self.handler()
            
            client?.urlProtocol(self, didReceive: handlerResult.response, cacheStoragePolicy: .allowed)
            client?.urlProtocol(self, didLoad: handlerResult.data)
            client?.urlProtocolDidFinishLoading(self)
            
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    public override func stopLoading() {
        // This method is unused in the mock currently
    }
}
