import Foundation
@testable import Networking
import Security

final class MockCertificateEvaluator: SecurityEvaluator {
    
    var isServerTrusted: Bool = true
    var isCertificateValid: Bool = true
    var isCertificatePinned: Bool = true
    
    func evaluateServerTrust(for serverTrust: SecTrust, error: UnsafeMutablePointer<CFError?>?) -> Bool {
        isServerTrusted
    }
    
    func getTrustCertificate(for serverTrust: SecTrust, at index: Int) -> SecCertificate? {
        if !isCertificateValid { return nil }
        
        let certificateData: Data
        
        if isCertificatePinned {
            certificateData = Certificates.amazonRootCA1.data
        } else if let url = Bundle.module
            .url(forResource: "stackexchange", withExtension: "der"),
                  let data = try? Data(contentsOf: url) {
            certificateData = data
        } else {
            preconditionFailure("Unable to find test certificate in bundle")
        }
        
        let certificate = SecCertificateCreateWithData(nil,
                                                       certificateData as NSData as CFData)
        
        return isCertificatePinned ? certificate : certificate
    }
}
