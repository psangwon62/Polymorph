import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: "ImageProcessing",
    schemes: [
        .scheme(name: "ImageProcessingExample",
                buildAction: .buildAction(targets: ["ImageProcessingExample"]),
                runAction: .runAction(executable: "ImageProcessingExample")),
        .scheme(
            name: "ImageProcessingTests",
            testAction: .targets(["ImageProcessingTests"])
        ),
    ]
)
