// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ClockMac",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "ClockMac",
            path: "Sources/ClockMac"
        )
    ]
)
