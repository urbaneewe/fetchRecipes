// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let packageName = "LocalPackages"

func uiPath(_ subPath: String) -> String { return "Sources/UI/\(subPath)" }

let package = Package(
    name: packageName,
    defaultLocalization: "en", platforms: [.iOS("17.0")],
    products: [
        .library(name: "FetchAppUI", targets: ["Recipes"])
    ],
    targets: [
        .target(
            name: "Recipes",
            path: uiPath("Recipes")
        )
    ]
)
