// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "Networking", targets: ["Networking"]),
        .library(name: "MockNetworking", targets: ["MockNetworking"]),
        .library(name: "TokenGeneration", targets: ["TokenGeneration"])
    ],
    targets: [
        .target(name: "Networking",
                resources: [.process("Pinning/Certificates")],
                swiftSettings: [
                    .define("DEBUG", .when(configuration: .debug))
                ]
               ),
        .target(name: "MockNetworking", dependencies: ["Networking"]),
        .target(name: "TokenGeneration"),
        .testTarget(name: "NetworkingTests",
                    dependencies: ["Networking", "MockNetworking"],
                    resources: [.process("Pinning/Certificates")]),
        .testTarget(name: "TokenGenerationTests", dependencies: ["TokenGeneration"])
    ]
)
