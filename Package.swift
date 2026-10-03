// swift-tools-version: 6.0
import PackageDescription

let package = Package(
	name: "EndpointKit",
	platforms: [
		.macOS(.v13),
		.iOS(.v16),
		.tvOS(.v16),
		.watchOS(.v9),
		.visionOS(.v1),
	],
	products: [
		.library(
			name: "EndpointKit",
			targets: ["EndpointKit"]
		)
	],
	targets: [
		.target(
			name: "EndpointKit",
		),
		.testTarget(
			name: "EndpointKitTests",
			dependencies: ["EndpointKit"],
		),
	]
)

for target in package.targets where target.type != .plugin {
	var settings = target.swiftSettings ?? []
	settings.append(contentsOf: [
		.swiftLanguageMode(.v6),
		.enableUpcomingFeature("ApproachableConcurrency"),
	])
	target.swiftSettings = settings
}
