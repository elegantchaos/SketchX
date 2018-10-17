// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SketchX",
    products: [
        .executable(name: "sketchx", targets: ["SketchX"])
    ],
    dependencies: [
        .package(url: "https://github.com/elegantchaos/Arguments", from: "1.0.0"),
        .package(url: "https://github.com/elegantchaos/Runner", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SketchX",
            dependencies: ["Arguments", "Runner"]),
        .testTarget(
            name: "SketchXTests",
            dependencies: ["SketchX"]),
    ]
)
