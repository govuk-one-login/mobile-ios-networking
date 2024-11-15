import Foundation

public struct SignedJWTGenerator: JWTGenerator {
    let signer: SigningService

    func generate(
        header: [String: Any],
        payload: [String: Any]
    ) throws -> String {
        let headerData = try header.jsonData
        let payloadData = try payload.jsonData
        
        guard let headerJSONString = String(data: headerData, encoding: .utf8),
              let payloadJSONString = String(data: payloadData, encoding: .utf8) else {
            throw SignedJWTGeneratorError.cantCreateJSONString
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