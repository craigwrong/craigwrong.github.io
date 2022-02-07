// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "craigwrong",
    platforms: [.macOS(.v11)],
    dependencies: [
        .package(url: "https://github.com/swiftysites/swiftysites", .branch("release"))],
    targets: [
        .executableTarget(
            name: "swiftysites",
            dependencies: [
                .product(name: "SwiftySites", package: "swiftysites")
            ],
            path: "src")])
