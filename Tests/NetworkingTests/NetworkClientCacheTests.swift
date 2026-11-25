import Foundation
import MockNetworking
@testable import Networking
import Testing

struct NetworkClientCacheTests {
    @Test("The default initialiser uses the shared cache")
    func test_convenienceInit_usesSharedCache() {
        let sut = NetworkClient()

        #expect(sut.debugSession.configuration.urlCache === URLCache.shared)
    }

    @Test("init(urlCache:) uses the injected cache and keeps the standard configuration")
    func test_urlCacheInit_usesInjectedCache() {
        let cache = URLCache(memoryCapacity: 1_000_000, diskCapacity: 0)

        let sut = NetworkClient(urlCache: cache)
        let config = sut.debugSession.configuration

        #expect(config.urlCache === cache)
        #expect(config.urlCache !== URLCache.shared)
        #expect(config.requestCachePolicy == .useProtocolCachePolicy)
        #expect(config.tlsMinimumSupportedProtocolVersion == .TLSv12)
        #expect(config.httpAdditionalHeaders?["User-Agent"] as? String == UserAgent().description)
    }

    @Test("A client with an injected cache stores responses there and not in the shared cache")
    func test_injectedCache_receivesStoredResponsesInsteadOfSharedCache() async throws {
        let cache = URLCache(memoryCapacity: 1_000_000, diskCapacity: 0)
        let url = URL.example
        let request = URLRequest(url: url)
        URLCache.shared.removeCachedResponse(for: request)
        defer { MockURLProtocol.clear() }

        // `init(urlCache:)` cannot take a mock `URLProtocol`, so build the equivalent
        // configuration by hand. Its wiring is covered by `test_urlCacheInit_usesInjectedCache`.
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .useProtocolCachePolicy
        config.urlCache = cache
        config.protocolClasses = [MockURLProtocol.self]
        let sut = NetworkClient(configuration: config)

        let body = Data("cached body".utf8)
        let response = try #require(HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Cache-Control": "max-age=3600"]
        ))
        MockURLProtocol.handler = { (body, response) }

        let first = try await sut.request(request).execute()
        #expect(first == body)

        // The cache write can complete asynchronously, so wait for it.
        for _ in 0..<50 where cache.cachedResponse(for: request) == nil {
            try await Task.sleep(nanoseconds: 20_000_000)
        }
        #expect(cache.cachedResponse(for: request)?.data == body)
        #expect(URLCache.shared.cachedResponse(for: request) == nil)
    }
}
