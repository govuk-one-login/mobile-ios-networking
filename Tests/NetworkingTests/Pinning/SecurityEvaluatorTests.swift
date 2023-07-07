@testable import Networking
import XCTest

final class X509CertificateSecurityEvaluatorTests: XCTestCase {
    var sut: X509CertificateSecurityEvaluator!
    
    override func setUp() {
        super.setUp()
        sut = X509CertificateSecurityEvaluator()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    /* A valid challenge would be needed from URLAuthenticationChallenge
     to create a serverTrust that would evaluate to `true`. Also, it would
     rely on a network connection. */
    func test_evaluateServerTrust_untrusted() {
        guard let serverTrust = serverTrust else {
            XCTFail("Exptected a valid value for server trust")
            return
        }
        XCTAssertFalse(sut.evaluateServerTrust(for: serverTrust, error: nil))
    }
    
    /* Set a policy for evaluating SSL certificate chains */
    private func applySSLTrustPolicy(from challenge: URLAuthenticationChallenge,
                                     to serverTrust: SecTrust) -> Bool {
        let policies = NSMutableArray()
        policies.add(SecPolicyCreateSSL(true, (challenge.protectionSpace.host as CFString)))
        SecTrustSetPolicies(serverTrust, policies)
        return true
    }
    
    func test_getTrustCertificate_success() {
        guard let serverTrust = serverTrust else {
            XCTFail("Exptected a valid value for server trust")
            return
        }
        XCTAssertNotNil(sut.getTrustCertificate(for: serverTrust, at: 0))
    }
    
    private var serverTrust: SecTrust? {
        let cfTrustPointer = UnsafeMutablePointer<SecTrust?>.allocate(capacity: 1000)
        let certificateData = Certificates.amazonRootCA1.data
        let certificateRef = SecCertificateCreateWithData(nil, certificateData as NSData as CFData)
        SecTrustCreateWithCertificates(certificateRef as CFTypeRef,
                                       SecPolicyCreateSSL(true, "myhost.com" as CFString),
                                       cfTrustPointer)
        return cfTrustPointer.pointee
    }
}
