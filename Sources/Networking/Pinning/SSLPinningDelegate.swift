import Foundation

/// SSLPinningDelegate
///
/// Delegate class to handle certificate pinning. Certificate pinning is the process of associating the backend server with a particular
/// X509 certificate or public key instead of accepting any certificate signed by a trusted certificate authority.
/// Having pinned a certificate, the server certificate will subsequently only establish connections to the known server.
final class SSLPinningDelegate: NSObject, URLSessionDelegate {
    enum SSLPinningError: Error {
        case serverTrustMissingFromChallenge
        case serverNotTrusted
        case noCertificateFoundOnServer
        case certificateNotPinnedInBundle
    }
    
    let evaluator: SecurityEvaluator
//    let catchBlock: ((Error) -> Void)? /* This catchBlock is only used to unit test error handling */

    init(with evaluator: SecurityEvaluator = X509CertificateSecurityEvaluator()
//         catchBlock: ((Error?) -> Void)? = nil
    ) {
        self.evaluator = evaluator
//        self.catchBlock = catchBlock
    }
    
    /// urlSession
    ///
    /// Requests credentials from the delegate in response to a session-level authentication request from the remote server.
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        do {
            let serverTrust = try x509CertificateServerTrust(from: challenge)
            try evaluateCertificate(from: serverTrust)
            let credential: URLCredential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } catch {
            completionHandler(.cancelAuthenticationChallenge, nil)
//            catchBlock?(error)
        }
    }

    /// x509CertificateServerTrust
    ///
    /// Evaluate trust of the server and return a Trust object with which to evaluate the certificates
    private func x509CertificateServerTrust(from challenge: URLAuthenticationChallenge) throws -> SecTrust {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            throw SSLPinningError.serverTrustMissingFromChallenge
        }
        
        guard applySSLTrustPolicy(from: challenge, to: serverTrust),
            evaluator.evaluateServerTrust(for: serverTrust, error: nil) else {
                throw SSLPinningError.serverNotTrusted
        }
        return serverTrust
    }
    
    /// applySSLTrustPolicy
    ///
    /// Set a policy for evaluating SSL certificate chains
    private func applySSLTrustPolicy(from challenge: URLAuthenticationChallenge,
                                     to serverTrust: SecTrust) -> Bool {
        let policies = NSMutableArray()
        policies.add(SecPolicyCreateSSL(true, (challenge.protectionSpace.host as CFString)))
        SecTrustSetPolicies(serverTrust, policies)
        return true
    }
    
    /// evaluateCertificate
    ///
    /// Retrieves a certificate from the server during handshake and checks for a match against pinned certificates
    private func evaluateCertificate(from serverTrust: SecTrust) throws {
        guard let remoteCertificate = evaluator.getTrustCertificate(for: serverTrust, at: 0) else {
            throw SSLPinningError.noCertificateFoundOnServer
        }
        
        guard Certificates.contains(remoteCertificate: remoteCertificate) else {
            throw SSLPinningError.certificateNotPinnedInBundle
        }
    }
}
