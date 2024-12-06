import Foundation.NSData
import Testing
@testable import TokenGeneration

struct JWTGeneratorTests {
    let mockJWTSigningService = MockJWTSigningService()
    
    @Test
    func generateJWTWithStrings() throws {
        let header = ["header_key_1": "header_value_1"]
        let payload = ["payload_key_1": "payload_value_1"]
        
        let jwtRepresentation = JWTRepresentation(
            header: header,
            payload: payload
        )
        let sut = JWTGenerator(
            jwtRepresentation: jwtRepresentation,
            signingService: mockJWTSigningService
        )
        let jwt = try sut.token
        
        let headerJSON = try JSONSerialization.data(withJSONObject: header)
        let payloadJSON = try JSONSerialization.data(withJSONObject: payload)
        let signature = try createSignatureFromJSON(headerJSON: headerJSON, payloadJSON: payloadJSON)
        
        let components = jwt.components(separatedBy: ".")
        #expect(components.count == 3)
        
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
        
        let jwtRepresentation = JWTRepresentation(
            header: header,
            payload: payload
        )
        let sut = JWTGenerator(
            jwtRepresentation: jwtRepresentation,
            signingService: mockJWTSigningService
        )
        let jwt = try sut.token
        
        let headerJSON = try JSONSerialization.data(withJSONObject: header)
        let payloadJSON = try JSONSerialization.data(withJSONObject: payload)
        let signature = try createSignatureFromJSON(headerJSON: headerJSON, payloadJSON: payloadJSON)
        
        let components = jwt.components(separatedBy: ".")
        #expect(components.count == 3)

        #expect(components[0] == headerJSON.base64URLEncodedString)
        #expect(components[1] == payloadJSON.base64URLEncodedString)
        #expect(components[2] == signature.base64URLEncodedString)
    }
    
    private func createSignatureFromJSON(headerJSON: Data, payloadJSON: Data) throws -> Data {
        let encodedHeaderJSON = headerJSON.base64URLEncodedString
        let encodedPayloadJSON = payloadJSON.base64URLEncodedString
        return Data((encodedHeaderJSON + "." + encodedPayloadJSON).utf8)
    }
}
