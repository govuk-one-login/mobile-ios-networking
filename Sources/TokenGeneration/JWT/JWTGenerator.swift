import Foundation.NSData

public struct JWTGenerator {
    private let jwtRepresentation: JWTRepresentation
    private let signingService: JWTSigningService
    
    public init(jwtRepresentation: JWTRepresentation,
                signingService: JWTSigningService) {
        self.jwtRepresentation = jwtRepresentation
        self.signingService = signingService
    }
    
    public var token: String {
        get throws {
            guard let headerJSONData = try? JSONSerialization.data(withJSONObject: jwtRepresentation.header),
                  let payloadJSONData = try? JSONSerialization.data(withJSONObject: jwtRepresentation.payload) else {
                throw JWTGeneratorError.cantCreateJSONData
            }
            
            let encodedHeaderJSONData = headerJSONData.base64URLEncodedString
            let encodedPayloadJSONData = payloadJSONData.base64URLEncodedString
            
            let signableJSONData = encodedHeaderJSONData + "." + encodedPayloadJSONData
            let dataToSign = Data(signableJSONData.utf8)
            let signature = try signingService.sign(data: dataToSign)

            let encodedSignature = signature.base64URLEncodedString
            
            return "\(encodedHeaderJSONData).\(encodedPayloadJSONData).\(encodedSignature)"
        }
    }
}
