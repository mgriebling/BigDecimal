// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BigDecimal",
    platforms: [
        .macOS("15.0"), .iOS("18.0"), .macCatalyst("15.0"), .tvOS("18.0"),
        .watchOS("11.0")
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BigDecimal",
            targets: ["BigDecimal"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/mgriebling/BigInt.git", from: "2.0.11"),
        // .package(url: "https://github.com/mgriebling/UInt128.git", from: "3.0.0")
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BigDecimal",
            dependencies: ["BigInt",
                      .product(name: "Numerics", package: "swift-numerics")]),
        .testTarget(
            name: "BigDecimalTests",
            dependencies: ["BigDecimal"]),
    ]
)

