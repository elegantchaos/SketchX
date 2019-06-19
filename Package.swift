// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SketchX",
    
    platforms: [
        .macOS(.v10_13)
    ],
    
    products: [
        .executable(name: "sketchx", targets: ["SketchX"])
    ],
    
    dependencies: [
        .package(url: "https://github.com/elegantchaos/Runner.git", from: "1.0.3"),
        .package(url: "https://github.com/elegantchaos/CommandShell.git", from: "1.1.0"),
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
