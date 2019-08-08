// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Updates",
    platforms: [
        .iOS("9.0")
    ],
    products: [
        .library(
            name: "Updates",
            targets: ["Updates"]
        )
    ],
    targets: [
        /*.target(
            name: "UpdatesUI",
            dependencies: ["Updates"],
            path: "Updates/Classes/UI"
        ),*/
        .target(
            name: "Updates",
            dependencies: [],
            path: "Updates/Classes",
            exclude: ["UI"]
        )
    ]
)
