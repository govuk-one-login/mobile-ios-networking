// Deliberately not `@testable`: this file only compiles if the APIs below are public,
// so they cannot silently become `internal`.
import Foundation
import Networking
import Testing

struct PublicAPITests {
    @Test("init(urlCache:) is public")
    func test_urlCacheInit_isPublic() {
        let cache = URLCache(memoryCapacity: 1_000_000, diskCapacity: 0)

        _ = NetworkClient(urlCache: cache)
    }
}
