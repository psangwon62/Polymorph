import ProjectDescription

public extension Project {
    static func module(
        name: String,
        targets: [Target.TargetType] = Target.TargetType.allCases,
        dependencies: [Target.TargetType: [TargetDependency]] = [:],
        schemes: [Scheme] = []
    ) -> Project {
        let adjustedTargets: [Target] = targets.compactMap { target in
            return .target(name: name, type: target, dependencies: dependencies[target] ?? [])
        }

        return Project(name: name, targets: adjustedTargets, schemes: schemes, fileHeaderTemplate: nil)
    }
}
