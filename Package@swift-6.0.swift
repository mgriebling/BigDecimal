// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "BigDecimal",
	platforms: [
		.macOS(.v15),
		.macCatalyst(.v18),
		.iOS(.v18),
		.tvOS(.v18),
		.watchOS(.v11),
		.visionOS(.v2),
	],
	products: [
		.library(name: "BigDecimal", targets: ["BigDecimal"]),
	],
	dependencies: [
		.package(url: "https://github.com/mgriebling/BigInt.git", from: "2.2.0"),
		.package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
		.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
	],
	targets: [
		.target(
			name: "BigDecimal",
			dependencies: [
				"BigInt",
				.product(name: "Numerics", package: "swift-numerics")
			]
		),
		.testTarget(
			name: "BigDecimalTests",
			dependencies: ["BigDecimal"]
		),
	]
)
