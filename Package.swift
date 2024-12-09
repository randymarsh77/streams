// swift-tools-version:6.0
import PackageDescription

let package = Package(
	name: "Streams",
	products: [
		.library(
			name: "Streams",
			targets: ["Streams"]
		)
	],
	dependencies: [
		.package(url: "https://github.com/randymarsh77/scope", branch: "master")
	],
	targets: [
		.target(
			name: "Streams",
			dependencies: [.product(name: "Scope", package: "Scope")]
		),
		.testTarget(name: "StreamsTests", dependencies: ["Streams"]),
	]
)
