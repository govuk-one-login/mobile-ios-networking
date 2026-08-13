import GDSUtilities
@testable import Networking
import Testing

struct AppIntegrityErrorTests {
    
    struct Case<Kind: GDSErrorKind>: Sendable {
        let error: NetworkingError<Kind>
        let debugDescription: String
        let kind: String
    }

    // swiftlint:disable line_length
    static let allNetworkingErrors = [
        Case(error: AppIntegrityError(.generic), debugDescription: "Error Domain=AppIntegrityErrorKind Code=1001 \"generic error\"", kind: "generic"),
        Case(error: AppIntegrityError(.intermittent), debugDescription: "Error Domain=AppIntegrityErrorKind Code=1002 \"intermittent error like network or server\"", kind: "intermittent"),
        Case(error: AppIntegrityError(.appIntegrityFailed), debugDescription: "Error Domain=AppIntegrityErrorKind Code=1003 \"app integrity has failed\"", kind: "appIntegrityFailed")
    ]
    // swiftlint:enable line_length

    @Test("assert debugDescription", arguments: AppIntegrityErrorTests.allNetworkingErrors)
    func test_debugDescription_AppIntegrityError(testCase: Case<AppIntegrityErrorKind>) async throws {
        #expect(testCase.error.debugDescription == testCase.debugDescription)
    }
    
    /// // swiftlint:disable line_length
    /// The `kind` found in the `userInfo` **must** hold a unique String identifier that describes the error as reported on analytics
    /// - Seealso: https://govukverify.atlassian.net/wiki/spaces/DCMAW/pages/3787195450/GOV.UK+One+Login+app+-+Error+handling#App-integrity-check-failures
    /// // swiftlint:enable line_length
    @Test("assert kind", arguments: AppIntegrityErrorTests.allNetworkingErrors)
    func test_kind_AppIntegrityError(testCase: Case<AppIntegrityErrorKind>) async throws {
        #expect(testCase.error.errorUserInfo["kind"] as? String == testCase.kind)
    }
}
