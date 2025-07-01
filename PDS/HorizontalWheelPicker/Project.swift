import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: "HorizontalWheelPicker",
    dependencies: [
        .feature: [
            .external(name: "PinLayout"),
            .external(name: "RxCocoa"),
            .external(name: "ReactorKit"),
        ],
    ],
    schemes: [
        .scheme(name: "HorizontalWheelPickerExample",
                buildAction: .buildAction(targets: ["HorizontalWheelPickerExample"]),
                runAction: .runAction(executable: "HorizontalWheelPickerExample")),
    ]
)
