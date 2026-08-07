@testable import Networking
import Testing

struct AppIntegrityErrorTests {
    @Test
    func test_generic_error() throws {
        let sut = AppIntegrityError(.generic)

        #expect(sut.debugDescription == "generic error")
    }
    
    @Test
    func test_intermittent_error() throws {
        let sut = AppIntegrityError(.intermittent)

        #expect(sut.debugDescription == "intermittent error like network or server")
    }
    
    @Test
    func test_appIntegrityFailed_error() throws {
        let sut = AppIntegrityError(.appIntegrityFailed)

        #expect(sut.debugDescription == "app integrity has failed")
    }
}
