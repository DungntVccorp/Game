import PackageDescription

let package = Package(
    name: "GameServer",
    targets: [
        Target(name: "Extension"),
        Target(name: "GameServer", dependencies: ["Extension"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/socks", majorVersion: 1),
        .Package(url: "https://github.com/alexeyxo/protobuf-swift", majorVersion: 3),
        .Package(url: "https://github.com/onevcat/Rainbow", majorVersion: 2),
        .Package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", majorVersion: 0),
        .Package(url: "https://github.com/IBM-Swift/Kitura-redis", majorVersion: 1),
        .Package(url: "https://github.com/IBM-Swift/Kassandra.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 1, minor: 0),
        ]
)
