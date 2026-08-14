// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "swiftui-markdown",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v2),
    ],
    products: [
        .library(name: "SwiftUIMarkdown", targets: ["SwiftUIMarkdown"]),
    ],
    targets: [
        .target(name: "SwiftUIMarkdown"),
        .testTarget(
            name: "SwiftUIMarkdownTests",
            dependencies: ["SwiftUIMarkdown"]
        ),
    ]
)
