@testable import Networking
import Foundation
import Testing

struct VersionTests {
    @Test("""
        Initialise Version from a string
    """)
    func string() {
        let sut = Version(string: "1.2.3")
        #expect(sut?.major == 1)
        #expect(sut?.minor == 2)
        #expect(sut?.increment == 3)
    }
    
    @Test("""
        Initialise Version by decoding from JSON
    """)
    func json() throws {
        let sut = try JSONDecoder()
            .decode(Version.self, from: Data(#""1.2.3""#.utf8))
        #expect(sut.major == 1)
        #expect(sut.minor == 2)
        #expect(sut.increment == 3)
    }
    
    @Test("""
        Error initialising Version by decoding from invalid JSON
    """)
    func jsonError() throws {
        #expect(throws: DecodingError.self) {
            try JSONDecoder()
                .decode(Version.self, from: Data(#""one.two.three""#.utf8))
        }
    }
    
    @Test("""
        Check comparable conformance works
    """)
    func compare() throws {
        var lower: Version
        var higher: Version
        lower = try #require(Version(string: "1.0.0"))
        higher = try #require(Version(string: "2.0.0"))
        #expect(lower < higher)
        
        lower = try #require(Version(string: "1.0.0"))
        higher = try #require(Version(string: "1.1.0"))
        #expect(lower < higher)
        
        lower = try #require(Version(string: "1.0.0"))
        higher = try #require(Version(string: "1.0.1"))
        #expect(lower < higher)
    }
}
