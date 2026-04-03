// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Squirrel",
    platforms: [.macOS(.v13)],
    targets: [
        .target(
            name: "SquirrelLib",
            path: "Sources/SquirrelLib"
        ),
        .executableTarget(
            name: "Squirrel",
            dependencies: ["SquirrelLib"],
            path: "Sources/Squirrel"
        ),
        .testTarget(
            name: "SquirrelTests",
            dependencies: ["SquirrelLib"],
            path: "Tests/SquirrelTests"
        ),
    ]
)
