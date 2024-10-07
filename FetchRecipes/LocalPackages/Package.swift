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
        .library(name: "FetchAppService", targets: ["RecipesService"]),
        .library(name: "FetchAppUI", targets: ["RecipesUI"])
    ],
    targets: [
        .target(
            name: "RecipesUI",
            dependencies: ["ViewStore", "RecipesService"],
            path: uiPath("Recipes")
        ),
        .target(name: "ViewStore"),
        .target(
            name: "RecipesService",
            dependencies: [],
            path: servicePath("Recipes")
        )
    ]
)
