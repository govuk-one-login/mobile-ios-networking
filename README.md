# Networking

Implementation of a Networking client and Mock Networking client module. Also a Token Generation module.

## Installation

To use Networking in a SwiftPM project:

1. Add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/govuk-one-login/mobile-ios-networking", from: "1.0.0"),
```

2. Add `Networking` as a dependency for your target:

```swift
.target(name: "MyTarget", dependencies: [
    .product(name: "Networking", package: "dcmaw-networking")
]),
```

Or for `MockNetworking`:
```swift
.testTarget(name: "MyTestTarget",
            dependencies: [
                "MyTarget",
                .product(name: "MockNetworking", package: "Networking")
            ]
)
```

3. Add `import Networking`, `import MockNetworking` or `import TokenGeneration` in your source code.

## Package description

## Networking

The `Networking` module is a unified implementation for networking to ensure that all HTTP requests made from the app are consistently well-formed. It also ensures that requests are pinned (to Amazon Root Certificates) and a user agent is attached.

Certificate pinning is not recommended in general for mobile applications, given the sensitive nature of our applications, we have decided to add this as an additional layer of protection against man-in-the-middle attacks.

The iOS validation would need to be set-up in your app codebase Info.plist for devices which are running iOS 14 or later. [The Apple Developer documentation](https://developer.apple.com/news/?id=g9ejcf8y) explains how this is set up. There is no additional setup for devices running iOS 13 or lower, as we have included that in this package.

> Within Sources/Networking exist the following protocols and Type for enabling the app to make network requests and pin certificates.

### Protocols

`AppBundle` used to extend `Bundle` to provide an abstraction layer to decouple required properties for use in `UserAgent` struct and in mocks.

`Device` used to extend `Bundle` to provide an abstraction layer to decouple required properties for use in `UserAgent` struct and in mocks.

`SecurityEvaluator` for evaluating server trust and getting certificates


### Types

#### NetworkClient
`NetworkClient` is a class with two public async throwing methods called `makeRequest` and `makeAuthorizedRequest` which handle network requests and return `Data`. 

`NetworkClient` is initialised with a `URLSessionConfiguration`. It has a `convenience init` that initialises `configuration` with the `.ephemeral` singleton on `URLSessionConfiguration` which avoids needing to provide one at initialisation.

For iOS 14 and later, certificates are pinned using `NSAppTransportSecurity`. Earlier versions of iOS use `SSLPinningDelegate` which conforms to `URLSessionDelegate` protocol to handle certificate pinning.

The signature of the `makeRequest` method is:

```swift
public func makeRequest(_ request: URLRequest) async throws -> Data
```

The signature of the `makeAuthorizedRequest` method is:

```swift
public func makeAuthorizedRequest(exchangeRequest: URLRequest,
                                  scope: String,
                                  request: URLRequest) async throws -> Data
```

Both of these methods handle various response types and return or throw errors as appropriate.

The `URLSessionConfiguration.tlsMinimumSupportedProtocolVersion` is then set to `.TLSv12` and `.httpAdditionalHeaders` is set like so:

```swift
configuration.httpAdditionalHeaders = ["User-Agent": UserAgent().description]
```

#### SSLPinningDelegate
`SSLPinningDelegate` class is used for handling certificate pinning in iOS 13 and earlier. In the ``NetworkClient`` initialiser it is called conditionally.

Conforms to: `NSObject`, `URLSessionDelegate`

#### X509CertificateSecurityEvaluator
`X509CertificateSecurityEvaluator` concrete implementation of `SecurityEvaulator`

Conforms to: `SecurityEvaluator`

#### UserAgent
`UserAgent` is a struct encapsulating helpful additional information to be included in HTTP headers when making network requests.

This enables us to see in our backend logs with version of the app is making the call, making it easier for us to triage issues and fix bugs.

Conforms to: `CustomStringConvertible`

You can set various details in the UserAgent, line in the below samples. It will also set the app name from `CFBundleName` and the version from `CFBundleShortVersionString`. We pass these through to a `description` element and then use that with the network call. For example, for [GOV.UK ID Check](https://apps.apple.com/gb/app/gov-uk-id-check/id1629050566) 1.18.0 running on [iPhone SE 2](https://gist.github.com/adamawolf/3048717) on iOS 16.5.1, this would show up as `ID_Check/1.18.0 iPhone12,8 iOS/16.5.1 CFNetwork/1408.0.4 Darwin/22.5.0`

```swift
    private var appInfo: String {
        "\(appName)/\(appVersion)"
    }
    
    var description: String {
        "\(appInfo) \(deviceModel) \(osVersion) \(cfNetwork) \(darwin)"
    }
```

#### DarwinVersion
`DarwinVersion` used as part of assembling the `UserAgent` properties. This type gets the `Darwin` version of the current OS from the `utsname` struct.

Conforms to: `CustomStringConvertible`

#### DeviceModel 
`DeviceModel` used as part of assembling the `UserAgent` properties. This type gets the device model from the `utsname` struct.

Conforms to: `CustomStringConvertible`

#### Version 
`Version` used as part of assembling the `UserAgent` properties. It has two initialisers. The one used when creating the `UserAgent` takes a `String` argument and separates it into components for `major`, `minor` and `increment` version numbers which are then stored in constant properties. The other initialiser accepts separate `Int` types directly for `major`, `minor` and `increment`.

Conforms to: `CustomStringConvertible`, `Decodable` and `Comparable`.


### Extensions

Extension on `HTTPURLResponse` adds an `isSuccessful` bool computed property that based on the `statusCode` of the response. For `statusCode` in the range 200 to 299 inclusive it returns `true`, otherwise it returns `false`. This allows querying HTTP response codes directly on the HTTP response for example:

```swift
guard response.isSuccessful else {
// do work if unsuccessful
return
}
// do work if successful
```


## Error Handling

### Protocols
#### ErrorWithCode 
`ErrorWithCode` conforms to `Error` and includes the following requirements:

```swift
var hash: String? { get }
var errorCode: Int { get }
var endpoint: String? { get }
```

``errorCode`` being the HTTP error code from a network request and `endpoint` can be set when initialising the error.

There is a protocol extension on `ErrorWithCode` that returns and stores a hash from the `errorCode` and `endpoint` properties. This hash uses a deterministic hashing algorithm, as such, you can rely on the output hash being the same for consistent input values. This makes the `hash` property useful for error tracking and reporting via logging or analytics.

### Types
#### ServerError 
`ServerError` conforms to `ErrorWithCode`. It includes a constant string property `reason` which is set to `"server"`

There is then an extension on `ServerError` which adds a `parameters` dictionary computed property of type `[String: String]. This includes the `endpoint`, `code` (the `errorcode`), `hash` and `reason` properties. This is for analytics and logging purposes, allowing a single property to be submitted to a remote service if required.



## Example Implementation

### How to use the Network Client

To use the `NetworkClient` first make sure your module or app has a dependency on `Networking` and the file has an import for `Networking`. Then initialise an instance of `NetworkClient` and create a URLRequest. Then make the network request using the `makeRequest` method. 

```swift
import Networking

...

let client = NetworkClient() // initialised with URLSessionConfiguration.ephemeral

...

let requestURL = baseURL.appendingPathComponent("someURLPath")
var request = URLRequest(url: requestURL)
request.httpMethod = "GET"

do {
    let data = try await client.makeRequest(request)
    // decode data
} catch {
    // handle errors
}
```

How you handle the returned data would depend on what data you expect to be returned.


## TokenGeneration

The `TokenGeneration` module is intended to facilitate the creation of tokens which are commonly used to secure network calls.
The first (and currently only) token type which this module supports is a [JWT (JSON Web Token)](https://datatracker.ietf.org/doc/html/rfc7519).

### JWTGenerator
`JWTGenerator` is a type which takes a JWT Representation type which includes dictionaries for the header and payload of the JWT and a Signing Service which is used to create the JWT signature.
The format of a JWT is a header, a payload and a signed representation of the header and payload. These are concatendated, and therefore separated by "."s.
The header and payload elements of a JWT are JSON objects which are then base64 encoded, the signature is a signed representation of the header and payload, then base64 encoded. These are concatendated, and therefore separated by "."s to create a format suitable for reliable network transit.
