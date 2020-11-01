// swift-tools-version:5.1
import PackageDescription

let package = Package(
	name: "Streams",
	products: [
		.library(
			name: "Streams",
			targets: ["Streams"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/randymarsh77/scope", .branch("master")),
	],
	targets: [
		.target(
			name: "Streams",
			dependencies: ["Scope"]
		),
	]
)
