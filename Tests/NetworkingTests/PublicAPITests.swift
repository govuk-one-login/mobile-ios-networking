// Deliberately not `@testable`: this file only compiles if the APIs below are public,
// so they cannot silently become `internal`.
import Networking
import XCTest

final class PublicAPITests: XCTestCase {
    func test_urlCacheInit_isPublic() {
        let cache = URLCache(memoryCapacity: 1_000_000, diskCapacity: 0)

        _ = NetworkClient(urlCache: cache)
    }
}
