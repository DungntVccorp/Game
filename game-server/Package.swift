import PackageDescription

let package = Package(
    name: "game-server",
    dependencies: [
        .Package(url: "https://github.com/apple/swift-protobuf.git", Version(0,9,901)),
        ]
)
