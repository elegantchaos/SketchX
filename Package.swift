// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "SketchX",
    products: [
        .executable(name: "sketchx", targets: ["SketchX"])
    ],
    dependencies: [
        .package(url: "https://github.com/elegantchaos/Runner.git", from: "1.0.2"),
        .package(url: "https://github.com/elegantchaos/CommandShell.git", from: "1.0.5"),
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
