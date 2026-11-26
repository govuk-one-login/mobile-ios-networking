import Foundation

/// MockURLProtocol
///
/// Used for mocking a url response for unit testing.
public final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    private static let workQueue = DispatchQueue(label: "mock-url-protocol-work-queue")
    enum MockURLProtocolError: String, Error, Sendable {
        case noHandlerSet = "⚠️ Remember to set a handler closure when using MockURLProtocol"
    }
    
    nonisolated(unsafe) private static var _requests: [URLRequest] = []
    public static var requests: [URLRequest] {  workQueue.sync { _requests } }
    
    nonisolated(unsafe) private static var _handler: (() throws -> (data: Data, response: URLResponse)) = defaultHandler
    public static var handler: (() throws -> (data: Data, response: URLResponse)) {
        get { workQueue.sync { _handler } }
        set { workQueue.sync { _handler = newValue } }
    }
    
    nonisolated(unsafe) private static let defaultHandler: (() throws -> (Data, URLResponse)) = {
        assertionFailure(MockURLProtocolError.noHandlerSet.rawValue)
        throw MockURLProtocolError.noHandlerSet
    }
    
    public static func clear() {
        workQueue.sync {
            _requests = []
            _handler = defaultHandler
        }
    }
    
    public override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    public override static func canInit(with request: URLRequest) -> Bool {
        workQueue.sync {
            _requests.append(request)
        }

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

extension URLSessionConfiguration {
    func withMockURLProtocol() -> URLSessionConfiguration {
        protocolClasses = [MockURLProtocol.self]
        return self
    }
}
