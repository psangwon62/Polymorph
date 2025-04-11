import ProjectDescription

extension Project {
    static func module(name: String, dependencies: [TargetDependency] = []) -> Project {
        let targets: [Target] = [
            .target(
                name: "\(name)Interface",
                destinations: .iOS,
                product: .framework,
                bundleId: "com.example.\(name).interface",
                deploymentTargets: .iOS("16.0"),
                sources: "Interface/**",
                dependencies: dependencies
            ),
            .target(
                name: "\(name)",
                destinations: .iOS,
                product: .framework,
                bundleId: "com.example.\(name)",
                deploymentTargets: .iOS("16.0"),
                sources: "Sources/**",
                dependencies: []
            ),
            .target(
                name: "\(name)Tests",
                destinations: .iOS,
                product: .unitTests,
                bundleId: "com.example.\(name).tests",
                deploymentTargets: .iOS("16.0"),
                sources: "Tests/**",
                dependencies: [.target(name: "\(name)")]
            ),
            .target(
                name: "\(name)Testing",
                destinations: .iOS,
                product: .framework,
                bundleId: "com.example.\(name).testing",
                deploymentTargets: .iOS("16.0"),
                sources: "Testing/**",
                dependencies: [.target(name: "\(name)Interface")]
            ),
            .target(
                name: "\(name)Example",
                destinations: .iOS,
                product: .app,
                bundleId: "com.example.\(name).example",
                deploymentTargets: .iOS("16.0"),
                sources: "Tests/SnapshotTests/**",
                dependencies: [.target(name: "\(name)")]
            ),
        ]
        return Project(name: name, targets: targets)
    }
}
