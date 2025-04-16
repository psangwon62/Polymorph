import ProjectDescription
import ProjectDescriptionHelpers

private let name: Template.Attribute = .required("name")

private let template = Template(
    description: "TMA 모듈 템플릿",
    attributes: [
        name,
        .optional("platform", default: "ios"),
    ],
    items: [
        .interface(name),
        .feature(name),
        .tests(name),
        .testing(name),
        .example(name),
    ]
)
