// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "Updates",
    platforms: [
        .iOS("12.0"),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "Updates",
            targets: ["Updates"]
        )
    ],
    targets: [
        .target(
            name: "Updates",
            dependencies: [],
            path: "Updates/Classes",
            resources: [.copy("../../Example/Pods/Target Support Files/Updates/PrivacyInfo.xcprivacy")]
        )
    ]
)
