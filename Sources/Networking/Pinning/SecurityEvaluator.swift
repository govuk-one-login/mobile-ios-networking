import Foundation

/// SecurityEvaluator
///
/// Protocol with two methods. One for `evaluatingServerTrust` and a second for `getTrustCertificate`
protocol SecurityEvaluator: Sendable {
    func evaluateServerTrust(for serverTrust: SecTrust, error: UnsafeMutablePointer<CFError?>?) -> Bool
    func getTrustCertificate(for serverTrust: SecTrust, at index: Int) -> SecCertificate?
}

/// X509CertificateSecurityEvaluator
///
/// Concrete implementation of ``SecurityEvaluator``
final class X509CertificateSecurityEvaluator: SecurityEvaluator {
    
    func evaluateServerTrust(for serverTrust: SecTrust, error: UnsafeMutablePointer<CFError?>?) -> Bool {
        SecTrustEvaluateWithError(serverTrust, error)
    }
    
    func getTrustCertificate(for serverTrust: SecTrust, at index: Int) -> SecCertificate? {
        let certificateCount = SecTrustGetCertificateCount(serverTrust)
        return SecTrustGetCertificateAtIndex(serverTrust, certificateCount - 1)
    }
}
