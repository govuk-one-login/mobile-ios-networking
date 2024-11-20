import Foundation.NSData
import Testing
@testable import TokenGeneration

struct JWTGeneratorTests {
    let mockJWTSigningService = MockJWTSigningService()
    
    @Test
    func generateJWTWithStrings() throws {
        let header = ["header_key_1": "header_value_1"]
        let payload = ["payload_key_1": "payload_value_1"]
        
        let mockJWTRepresentation = JWTRepresentation(
            header: header,
            payload: payload
        )
        let sut = JWTGenerator(
            jwtRepresentation: mockJWTRepresentation,
            signingService: mockJWTSigningService
        )
        let jwt = try sut.token
        
        let components = jwt.components(separatedBy: ".")
        #expect(components.count == 3)
        
        let headerJSON = try header.jsonData
        let payloadJSON = try payload.jsonData
        let headerJSONString = try #require(String(data: headerJSON, encoding: .utf8))
        let payloadJSONString = try #require(String(data: payloadJSON, encoding: .utf8))
        let signature = Data((headerJSONString + "." + payloadJSONString).utf8)
        
        #expect(components[0] == headerJSON.base64URLEncodedString)
        #expect(components[1] == payloadJSON.base64URLEncodedString)
        #expect(components[2] == signature.base64URLEncodedString)
    }
    
    @Test
    func generateJWTWithBaseTypes() throws {
        let header: [String: Any] = [
            "header_key_1": "header_value_1",
            "header_key_2": 123456789,
            "header_key_3": true
        ]
        let payload: [String: Any] = [
            "payload_key_1": "payload_value_1",
            "payload_key_2": 987654321,
            "payload_key_3": false
        ]
        
        let mockJWTRepresentation = JWTRepresentation(
            header: header,
            payload: payload
        )
        let sut = JWTGenerator(
            jwtRepresentation: mockJWTRepresentation,
            signingService: mockJWTSigningService
        )
        let jwt = try sut.token
        
        let components = jwt.components(separatedBy: ".")
        #expect(components.count == 3)
        
        let headerJSON = try header.jsonData
        let payloadJSON = try payload.jsonData
        let headerJSONString = try #require(String(data: headerJSON, encoding: .utf8))
        let payloadJSONString = try #require(String(data: payloadJSON, encoding: .utf8))
        let signature = Data((headerJSONString + "." + payloadJSONString).utf8)

        #expect(components[0] == headerJSON.base64URLEncodedString)
        #expect(components[1] == payloadJSON.base64URLEncodedString)
        #expect(components[2] == signature.base64URLEncodedString)
    }
}
