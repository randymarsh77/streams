import PackageDescription

let package = Package(
    name: "Streams",
    dependencies: [
		.Package(url: "https://github.com/randymarsh77/scope", majorVersion: 1),
	]
)
