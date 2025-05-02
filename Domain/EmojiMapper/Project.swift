import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: "EmojiMapper",
    dependencies: [
        .example: [
            .project(target: "Logger", path: .relativeToRoot("Shared/Logger")),
        ],
    ],
    schemes: [
        .scheme(name: "EmojiMapperExample",
                buildAction: .buildAction(targets: ["EmojiMapperExample"]),
                runAction: .runAction(executable: "EmojiMapperExample")),
        .scheme(
            name: "EmojiMapperTests",
            testAction: .targets(["EmojiMapperTests"])
        ),
    ],
)
