import Foundation
@testable import Networking

final class MockAuthenticationProvider: AuthenticationProvider {
  var bearerToken: String = "testBearerToken"
}
