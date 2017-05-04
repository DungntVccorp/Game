import PackageDescription

let package = Package(
    name: "game-server",
    dependencies: [
        .Package(url: "https://github.com/apple/swift-protobuf.git", Version(0,9,901)),
        .Package(url: "https://github.com/IBM-Swift/Kitura-redis.git", Version(1,7,0)),
        ]
)
