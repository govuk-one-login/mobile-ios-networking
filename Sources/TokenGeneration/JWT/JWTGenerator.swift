import Foundation

public struct JWTGenerator {
    private let jwtRepresentation: JWTRepresentation
    private let signer: JWTSigningService
    
    public init(jwtRepresentation: JWTRepresentation,
                signer: JWTSigningService) {
        self.jwtRepresentation = jwtRepresentation
        self.signer = signer
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
            let signature = try signer.sign(data: dataToSign)
            
            let encodedHeader = headerData.base64EncodedString()
            let encodedPayload = payloadData.base64EncodedString()
            let encodedSignature = signature.base64EncodedString()
            
            return "\(encodedHeader).\(encodedPayload).\(encodedSignature)"
        }
    }
}
