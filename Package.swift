// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyBook",
    defaultLocalization: "ru",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .executable(name: "MyBookApp", targets: ["App"]),
        .library(name: "BooksFeature", targets: ["BooksFeature"]),
        .library(name: "LibraryFeature", targets: ["LibraryFeature"]),
        .library(name: "OrganizeFeature", targets: ["OrganizeFeature"]),
        .library(name: "CoreModels", targets: ["CoreModels"]),
        .library(name: "CoreUI", targets: ["CoreUI"])
    ],
    dependencies: [
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                "BooksFeature",
                "LibraryFeature",
                "OrganizeFeature",
                "CoreModels",
                "CoreUI"
            ],
            path: "Sources/App"
        ),
        .target(
            name: "BooksFeature",
            dependencies: ["CoreModels", "CoreUI"],
            path: "Sources/BooksFeature"
        ),
        .target(
            name: "LibraryFeature",
            dependencies: ["CoreModels", "CoreUI"],
            path: "Sources/LibraryFeature"
        ),
        .target(
            name: "OrganizeFeature",
            dependencies: ["CoreModels", "CoreUI"],
            path: "Sources/OrganizeFeature"
        ),
        .target(
            name: "CoreModels",
            path: "Sources/CoreModels"
        ),
        .target(
            name: "CoreUI",
            dependencies: ["CoreModels"],
            path: "Sources/CoreUI"
        ),
        .testTarget(
            name: "CoreModelsTests",
            dependencies: ["CoreModels"],
            path: "Tests/CoreModelsTests"

        )
    ]
)
