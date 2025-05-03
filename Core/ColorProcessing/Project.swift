import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: "ColorProcessing",
    dependencies: [
        .example: [
            .project(target: "Logger", path: .relativeToRoot("Shared/Logger")),
        ],
    ],
    schemes: [
        .scheme(name: "ColorProcessingExample",
                buildAction: .buildAction(targets: ["ColorProcessingExample"]),
                runAction: .runAction(executable: "ColorProcessingExample")),
        .scheme(
            name: "ColorProcessingTests",
            testAction: .targets(["ColorProcessingTests"])
        ),
    ]
)
