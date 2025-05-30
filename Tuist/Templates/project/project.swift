import ProjectDescription
import ProjectDescriptionHelpers

private let name: Template.Attribute = .required("name")

private let template = Template(
    description: "Project.swift 템플릿",
    attributes: [
        name,
        .optional("platform", default: "ios"),
    ],
    items: [
        .project(name),
    ]
)
