import ProjectDescription

let workspace = Workspace(
    name: "PolymorphWorkSpace",
    projects: [
        "App/**",
        "Domain/**",
        "Shared/**",
        "Feature/**",
    ],
    generationOptions: .options(
        autogeneratedWorkspaceSchemes: .disabled
    )
)
