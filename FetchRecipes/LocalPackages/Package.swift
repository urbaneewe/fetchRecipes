// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let packageName = "LocalPackages"

func uiPath(_ subPath: String) -> String { return "Sources/UI/\(subPath)" }
func servicePath(_ subPath: String) -> String { return "Sources/Service/\(subPath)" }

let package = Package(
    name: packageName,
    defaultLocalization: "en", platforms: [.iOS("17.0")],
    products: [
        .library(name: "Extensions", targets: ["Extensions"]),
        .library(name: "BackgroundColorManager", targets: ["BackgroundColorManager"]),
        .library(name: "FetchAppService", targets: ["RecipesService", "ServiceConfiguration"]),
        .library(name: "FetchAppUI", targets: ["RecipesUI"])
    ],
    targets: [
        .target(name: "Extensions"),
        .target(
            name: "BackgroundColorManager",
            dependencies: ["Extensions"]
        ),
        .target(
            name: "RecipesUI",
            dependencies: ["ViewStore", "RecipesService", "BackgroundColorManager"],
            path: uiPath("Recipes")
        ),
        .target(name: "ViewStore"),
        .target(
            name: "RecipesService",
            dependencies: ["ServiceConfiguration"],
            path: servicePath("Recipes")
        ),
        .target(
            name: "ServiceConfiguration",
            path: servicePath("ServiceConfiguration")
        )
    ]
)
