// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TimeRangePicker",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "TimeRangePicker",
            targets: ["TimeRangePicker"]),
    ],
    dependencies: [
        .package(url: "https://github.com/1amageek/ClockFace.git", branch: "main")
    ],
    targets: [
        .target(
            name: "TimeRangePicker",
            dependencies: ["ClockFace"]),
        .testTarget(
            name: "TimeRangePickerTests",
            dependencies: ["TimeRangePicker"]),
    ]
)
