@testable import MockNetworking
@testable import Networking
import XCTest

final class SSLPinningDelegateTests: XCTestCase {
    var urlSession: URLSession!
    var sut: SSLPinningDelegate!
    private var evaluator: MockCertificateEvaluator!
    var error: Error?
    
    override func setUp() {
        super.setUp()
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        urlSession = .init(configuration: configuration)
        
        evaluator = MockCertificateEvaluator()
        sut = SSLPinningDelegate(with: evaluator) {
            self.error = $0
        }
    }

    override func tearDown() {
        sut = nil
        evaluator = nil
        super.tearDown()
    }
    
    func test_didReceiveChallenge_success() {
        
        var challengeDisposition: URLSession.AuthChallengeDisposition?
        var credential: URLCredential?
        
        let completionHandler: ((URLSession.AuthChallengeDisposition, URLCredential?) -> Void) = { challengeDispositionResponse, credentialResponse in
            challengeDisposition = challengeDispositionResponse
            credential = credentialResponse
        }
        
        sut.urlSession(urlSession,
                       didReceive: authChallenge,
                       completionHandler: completionHandler)
        
        XCTAssertNil(error)
        XCTAssertNotNil(credential)
        XCTAssertTrue(challengeDisposition == .useCredential)
    }
    
    func test_didReceiveChallenge_failure_serverTrustMissingFromChallenge() {
            
        var challengeDisposition: URLSession.AuthChallengeDisposition?
        var credential: URLCredential?
        
        let completionHandler: ((URLSession.AuthChallengeDisposition, URLCredential?) -> Void) = { challengeDispositionResponse, credentialResponse in
            challengeDisposition = challengeDispositionResponse
            credential = credentialResponse
        }
    
        sut.urlSession(urlSession,
                       didReceive: URLAuthenticationChallenge.init(),
                       completionHandler: completionHandler)
        
        XCTAssertTrue(error as? SSLPinningDelegate.SSLPinningError == .serverTrustMissingFromChallenge)
        XCTAssertNil(credential)
        XCTAssertTrue(challengeDisposition == .cancelAuthenticationChallenge)
    }
    
    func test_didReceiveChallenge_failure_serverNotTrusted() {
            
        var challengeDisposition: URLSession.AuthChallengeDisposition?
        var credential: URLCredential?
        
        evaluator.isServerTrusted = false
        
        let completionHandler: ((URLSession.AuthChallengeDisposition, URLCredential?) -> Void) = { challengeDispositionResponse, credentialResponse in
            challengeDisposition = challengeDispositionResponse
            credential = credentialResponse
        }

        sut.urlSession(urlSession,
                       didReceive: authChallenge,
                       completionHandler: completionHandler)
        
        XCTAssertTrue(error as? SSLPinningDelegate.SSLPinningError == .serverNotTrusted)
        XCTAssertNil(credential)
        XCTAssertTrue(challengeDisposition == .cancelAuthenticationChallenge)
    }
    
    func test_didReceiveChallenge_failure_missingTrustCertificate() {
            
        var challengeDisposition: URLSession.AuthChallengeDisposition?
        var credential: URLCredential?
        
        evaluator.isCertificateValid = false
        
        let completionHandler: ((URLSession.AuthChallengeDisposition, URLCredential?) -> Void) = { challengeDispositionResponse, credentialResponse in
            challengeDisposition = challengeDispositionResponse
            credential = credentialResponse
        }
    
        sut.urlSession(urlSession,
                       didReceive: authChallenge,
                       completionHandler: completionHandler)
        
        XCTAssertNil(credential)
        XCTAssertTrue(error as? SSLPinningDelegate.SSLPinningError == .noCertificateFoundOnServer)
        XCTAssertTrue(challengeDisposition == .cancelAuthenticationChallenge)
    }

    func test_didReceiveChallenge_failure_certificateNotPinned() {
            
        var challengeDisposition: URLSession.AuthChallengeDisposition?
        var credential: URLCredential?
        
        evaluator.isCertificatePinned = false
        
        let completionHandler: ((URLSession.AuthChallengeDisposition, URLCredential?) -> Void) = { challengeDispositionResponse, credentialResponse in
            challengeDisposition = challengeDispositionResponse
            credential = credentialResponse
        }
    
        sut.urlSession(urlSession,
                       didReceive: authChallenge,
                       completionHandler: completionHandler)
        
        XCTAssertNil(credential)
        XCTAssertTrue(error as? SSLPinningDelegate.SSLPinningError == .certificateNotPinnedInBundle)
        XCTAssertTrue(challengeDisposition == .cancelAuthenticationChallenge)
    }
    
    private var authChallenge: URLAuthenticationChallenge {
        URLAuthenticationChallenge(protectionSpace: urlProtectionSpace,
                                   proposedCredential: nil,
                                   previousFailureCount: 0,
                                   failureResponse: nil,
                                   error: nil,
                                   sender: sut)
    }
    
    private var urlProtectionSpace: MockURLProtectionSpace {
        let protectionSpace = MockURLProtectionSpace(host: "myhost.com",
                                                     port: 443,
                                                     protocol: "https",
                                                     realm: nil,
                                                     authenticationMethod: NSURLAuthenticationMethodServerTrust)
        protectionSpace.internalServerTrust = serverTrust
        return protectionSpace
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

extension SSLPinningDelegate: URLAuthenticationChallengeSender {
    
    public func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {}
    
    public func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {}
    
    public func cancel(_ challenge: URLAuthenticationChallenge) {}
}

final class MockURLProtectionSpace: URLProtectionSpace {
    
    var internalServerTrust: SecTrust?
    
    override var serverTrust: SecTrust? {
        return internalServerTrust
    }
}
