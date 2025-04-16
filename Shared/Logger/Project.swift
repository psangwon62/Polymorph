import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: "Logger",
    schemes: [
        .scheme(
            name: "LoggerTests",
            testAction: .targets(["LoggerTests"])
        ),
    ]
)
