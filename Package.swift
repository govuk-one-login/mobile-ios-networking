// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "Networking", targets: ["Networking"]),
        .library(name: "MockNetworking", targets: ["MockNetworking"]),
        .library(name: "TokenGeneration", targets: ["TokenGeneration"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/govuk-one-login/mobile-ios-utilities",
            from: "1.0.0"
        )
    ],
    targets: [
        .target(name: "Networking",
                dependencies: [.product(name: "GDSUtilities", package: "mobile-ios-utilities")],
                swiftSettings: [
                    .define("DEBUG", .when(configuration: .debug))
                ]),
        .target(name: "MockNetworking", dependencies: ["Networking"]),
        .target(name: "TokenGeneration"),
        .testTarget(name: "NetworkingTests",
                    dependencies: [
                        "Networking",
                        "MockNetworking"
                    ]),
        .testTarget(name: "TokenGenerationTests",
                    dependencies: ["TokenGeneration"])
    ]
)
