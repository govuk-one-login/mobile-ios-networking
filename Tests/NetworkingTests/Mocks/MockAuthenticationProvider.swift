import Foundation
@testable import Networking

final class MockAuthenticationProvider: AuthenticationProvider {
    // swiftlint:disable line_length
  var bearerToken: String {
      """
zh2JZEiVWK9AHJNQN3TiK7MFjbuECjyA-I9uL9oFHmNZv0v4HnJrs64ZiNjp9nOSJjAM7gBIWJXlnzxG07/wzSE?neXnLinU6YYAZ!Q2CRwxkeqWT=hBapLWnbP1g/5j2MXlnY7gw2T=?i6nBI86=MJ1NR!fxqlwg4iI73x9HTL15i6urRrICHEps2BEy0c0uAet6USg6dpy0fFnf6Cf!ZozO37TOJB=T7!FooE8HDlM8WXggsO6cDQdDzRS43gL
"""
    // swiftlint:enable line_length
  }
}
