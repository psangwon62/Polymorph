import ProjectDescription
import ProjectDescriptionHelpers

private let name: Template.Attribute = .required("name")

private let template = Template(
    description: "Example 모듈 템플릿",
    attributes: [
        name,
        .optional("platform", default: "ios"),
    ],
    items: [
        .example(name),
    ]
)
