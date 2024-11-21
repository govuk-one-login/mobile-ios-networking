import Foundation.NSData

public struct JWTGenerator {
    private let jwtRepresentation: JWTRepresentation
    private let signingService: JWTSigningService
    
    public init(jwtRepresentation: JWTRepresentation,
                signingService: JWTSigningService) {
        self.jwtRepresentation = jwtRepresentation
        self.signingService = signingService
    }
    
    var token: String {
        get throws {
            guard let headerData = try? JSONSerialization.data(withJSONObject: jwtRepresentation.header),
                  let payloadData = try? JSONSerialization.data(withJSONObject: jwtRepresentation.payload) else {
                throw JWTGeneratorError.cantCreateJSONData
            }
            
            guard let headerJSONString = String(data: headerData, encoding: .utf8),
                  let payloadJSONString = String(data: payloadData, encoding: .utf8) else {
                throw JWTGeneratorError.cantCreateJSONString
            }
            
            let signableJSONString = headerJSONString + "." + payloadJSONString
            let dataToSign = Data(signableJSONString.utf8)
            let signature = try signingService.sign(data: dataToSign)
            
            let encodedHeader = headerData.base64URLEncodedString
            let encodedPayload = payloadData.base64URLEncodedString
            let encodedSignature = signature.base64URLEncodedString
            
            return "\(encodedHeader).\(encodedPayload).\(encodedSignature)"
        }
    }
}
