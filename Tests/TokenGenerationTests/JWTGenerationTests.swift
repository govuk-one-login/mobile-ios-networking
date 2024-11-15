import Foundation
import Testing
@testable import TokenGeneration

struct SignedJWTGeneratorTests {
    let mockSigner: MockSigner
    let sut: JWTGenerator
    
    init() {
        self.mockSigner = MockSigner()
        self.sut = JWTGenerator(signer: mockSigner)
    }
    
    @Test
    func generateJWTWithStrings() throws {
        let jwt = try sut.generateJWT(
            header: ["header_key_1": "header_value_1"],
            payload: ["payload_key_1": "payload_value_1"]
        )
        let components = try jwtToStringComponents(jwt)
        #expect(components[0] == "{\"header_key_1\":\"header_value_1\"}")
        #expect(components[1] == "{\"payload_key_1\":\"payload_value_1\"}")
        #expect(components[2] == "{\"header_key_1\":\"header_value_1\"}.{\"payload_key_1\":\"payload_value_1\"}")
    }
    
    @Test
    func generateJWTWithBaseTypes() throws {
        let jwt = try sut.generateJWT(
            header: [
                "header_key_1": "header_value_1",
                "header_key_2": 123456789,
                "header_key_3": true
            ],
            payload: [
                "payload_key_1": "payload_value_1",
                "payload_key_2": 987654321,
                "payload_key_3": false
            ]
        )
        let components = try jwtToStringComponents(jwt)
        #expect(components[0].contains("\"header_key_1\":\"header_value_1\""))
        #expect(components[0].contains("\"header_key_2\":123456789"))
        #expect(components[0].contains("\"header_key_3\":true"))
        #expect(components[1].contains("\"payload_key_1\":\"payload_value_1\""))
        #expect(components[1].contains("\"payload_key_2\":987654321"))
        #expect(components[1].contains("\"payload_key_3\":false"))
    }

}

extension SignedJWTGeneratorTests {
    func jwtToStringComponents(_ jwt: String) throws -> [String] {
        let components = jwt.components(separatedBy: ".")
        try #require(components.count == 3)
        return try components.map { component in
            let decodedData = try #require(Data(base64Encoded: component))
            return try #require(String(data: decodedData, encoding: .utf8))
        }
    }
}
