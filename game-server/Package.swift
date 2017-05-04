import PackageDescription

let package = Package(
    name: "game-server",
    targets: [
        Target(name: "Config", dependencies: []),
        Target(name: "game-server", dependencies: ["Config"]),
        ],
    dependencies: [
        .Package(url: "https://github.com/apple/swift-protobuf.git", Version(0,9,901)),
        .Package(url: "https://github.com/IBM-Swift/Kitura-redis.git", Version(1,7,0)),
        .Package(url: "https://github.com/1024jp/GzipSwift.git", Version(3,1,4)),
        ]
)
