// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "craigwrong",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/swiftysites/swiftysites", branch: "release")],
    targets: [
        .executableTarget(
            name: "swiftysites",
            dependencies: [
                .product(name: "SwiftySites", package: "swiftysites")
            ],
            path: "src")])
