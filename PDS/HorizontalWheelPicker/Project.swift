import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: "HorizontalWheelPicker",
    dependencies: [
        .feature: [.external(name: "PinLayout")],
    ]
)
