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
            let headerData = try jwtRepresentation.header.jsonData
            let payloadData = try jwtRepresentation.payload.jsonData
            
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
