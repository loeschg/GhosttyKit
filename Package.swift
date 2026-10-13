// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GhosttyKit",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "GhosttyKit", targets: ["GhosttyKit"]),
    ],
    targets: [
        // Built by build.sh from the Ghostty release with the same tag.
        .binaryTarget(
            name: "GhosttyKit",
            url: "https://github.com/loeschg/GhosttyKit/releases/download/1.3.1/GhosttyKit.xcframework.zip",
            checksum: "269e6a4ac841411614cdc326a6bf1934b51b6556000efc54d794ba35b3cb291c"
        ),
    ]
)
