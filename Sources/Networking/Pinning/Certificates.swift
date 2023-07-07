import CommonCrypto
import Foundation

enum Certificates: String, CaseIterable {
    case amazonRootCA1
    case amazonRootCA2
    case amazonRootCA3
    case amazonRootCA4
    case starfieldRootCA
}

extension Certificates {
    static func contains(remoteCertificate: SecCertificate) -> Bool {
        let remoteData: NSData = SecCertificateCopyData(remoteCertificate)
        return Certificates.allCases.lazy.map { $0.data }
            .contains(where: { remoteData.isEqual(to: $0) })
    }
    
    var data: Data {
        guard let url = Bundle.module.url(forResource: rawValue, withExtension: "der"),
              let data = try? Data(contentsOf: url),
              data.checksum == checksum else {
            preconditionFailure("Certificate file was not present in bundle")
        }
        return data
    }
    
    var checksum: String {
        switch self {
        case .amazonRootCA1: return "8ecde6884f3d87b1125ba31ac3fcb13d7016de7f57cc904fe1cb97c6ae98196e"
        case .amazonRootCA2: return "1ba5b2aa8c65401a82960118f80bec4f62304d83cec4713a19c39c011ea46db4"
        case .amazonRootCA3: return "18ce6cfe7bf14e60b2e347b8dfe868cb31d02ebb3ada271569f50343b46db3a4"
        case .amazonRootCA4: return "e35d28419ed02025cfa69038cd623962458da5c695fbdea3c22b0bfb25897092"
        case .starfieldRootCA: return "568d6905a2c88708a4b3025190edcfedb1974a606a13c6e5290fcb2ae63edab5"
        }
    }
}

extension Data {
    fileprivate var checksum: String {
        let digestLength: Int32 = CC_SHA256_DIGEST_LENGTH
        let digestCount: Int = Int(digestLength)
        var digest = [UInt8](repeating: 0, count: digestCount)
        hash(&digest)
        return data(from: digest)
    }
    
    private func hash(_ digest: inout [UInt8]) {
        withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(count), &digest)
        }
    }
    
    private func data(from digest: [UInt8]) -> String {
        Data(digest).map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}
