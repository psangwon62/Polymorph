import ProjectDescription

let project = Project(
    name: "Emojis",
    targets: [
        .target(
            name: "EmojisInterface",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.sangwon.polymorph.emojisinterface",
            deploymentTargets: .iOS("16.0"),
            sources: ["Interface/**"]
        ),
        .target(
            name: "Emojis",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.sangwon.polymorph.emojis",
            deploymentTargets: .iOS("16.0"),
            sources: ["Sources/**"],
            dependencies: [
                .target(name: "EmojisInterface"),
            ]
        ),
        .target(
            name: "EmojisTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.sangwon.polymorph.emojistests",
            deploymentTargets: .iOS("16.0"),
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "Emojis"),
            ]
        ),
    ],
    fileHeaderTemplate: nil
)
