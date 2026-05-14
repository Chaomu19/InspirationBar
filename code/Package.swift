// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "InspirationBar",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "InspirationBar", targets: ["InspirationBar"]),
    ],
    dependencies: [
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "InspirationBar",
            dependencies: [
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
            ],
            path: "Sources/InspirationBar",
            exclude: ["Resources"]
        ),
        .testTarget(
            name: "InspirationBarTests",
            dependencies: ["InspirationBar"],
            path: "Tests/InspirationBarTests"
        ),
    ]
)
