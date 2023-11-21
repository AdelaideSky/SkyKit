// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SkyKit",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
//        .library(
//            name: "SkyKit_Design",
//            targets: ["SkyKit_Design"]),
        .library(
            name: "SkyKit",
            targets: ["SkyKit"]),
        .library(
            name: "SkyCharts",
            targets: ["SkyCharts"]),
        .library(
            name: "SkyKitC",
            targets: ["SkyKitC"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.6.1")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SkyKit",
            dependencies: ["Alamofire", "SwiftyJSON", "SkyKitC"],
            resources: [.process("Resources")]),
        .target(
            name: "SkyCharts",
            dependencies: ["Alamofire", "SwiftyJSON", "SkyKitC"]),
        .target(name: "SkyKitC"),
        .testTarget(
            name: "SkyKitTests",
            dependencies: ["SkyKit"]),
    ]
)
