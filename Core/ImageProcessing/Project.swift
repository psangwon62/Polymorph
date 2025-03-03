import ProjectDescription

let project = Project(
    name: "ImageProcessing",
    targets: [
        .target(
            name: "ImageProcessingInterface",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.sangwon.polymorph.imageprocessinginterface",
            deploymentTargets: .iOS("16.0"),
            sources: ["Interface/**"]
        ),
        .target(
            name: "ImageProcessing",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.sangwon.polymorph.imageprocessing",
            deploymentTargets: .iOS("16.0"),
            sources: ["Sources/**"],
            dependencies: [
                .target(name: "ImageProcessingInterface"),
            ]
        ),
        .target(
            name: "ImageProcessingTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.sangwon.polymorph.imageprocessingtests",
            deploymentTargets: .iOS("16.0"),
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "ImageProcessing"),
            ]
        ),
    ],
    fileHeaderTemplate: nil
)
