import PackageDescription

let package = Package(
    name: "GS",
    targets: [
        Target(name: "Commessage"),
        Target(name: "Core"),
        Target(name: "Communication",dependencies: ["Core","Commessage"]),
        Target(name: "OperationTask",dependencies: ["Core"]),
        Target(name: "Log",dependencies: ["Core"]),        
        Target(name: "GS",dependencies: ["Core","Communication","OperationTask","Log"])        
        ],
    dependencies: [
        .Package(url: "https://github.com/apple/swift-protobuf.git", Version(0,9,24)),
        .Package(url: "https://github.com/IBM-Swift/BlueSocket", Version(0,12,16)),
        .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", Version(1,4,0)),
        ]
)
