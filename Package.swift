// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "SketchX",
    products: [
        .executable(name: "sketchx", targets: ["SketchX"])
    ],
    dependencies: [
        .package(url: "https://github.com/elegantchaos/Runner", from: "1.0.1"),
        .package(url: "https://github.com/elegantchaos/CommandShell", from: "1.0.1"),
    ],
    targets: [
        .target(
            name: "SketchX",
            dependencies: ["Runner", "CommandShell"]),
        .testTarget(
            name: "SketchXTests",
            dependencies: ["SketchX"]),
    ]
)
