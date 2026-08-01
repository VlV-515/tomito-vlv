// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "tomito-vlv",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "Tomito-vlv", targets: ["TomitoVLv"])
    ],
    targets: [
        .executableTarget(
            name: "TomitoVLv",
            path: "Sources/TomitoVLv",
            resources: [.process("Resources")]
        )
    ]
)
