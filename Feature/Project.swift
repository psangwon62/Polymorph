import ProjectDescription

let project = Project(
    name: "Feature",
    targets: [
        .target(
            name: "FeatureInterface",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.sangwon.polymorph.featureinterface",
            sources: ["Interface/**"]
        ),
        .target(
            name: "Feature",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.sangwon.polymorph.feature",
            sources: ["Sources/**"],
            dependencies: [
                .target(name: "FeatureInterface"),
            ]
        ),
        .target(
            name: "FeatureTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.sangwon.polymorph.featuretests",
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "Feature"),
            ]
        ),
    ],
    fileHeaderTemplate: nil
)
