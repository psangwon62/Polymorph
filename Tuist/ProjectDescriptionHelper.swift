import ProjectDescription

extension String {
    var firstCharacterUppercased: String {
        guard let first = first else {
            return ""
        }
        let rest = dropFirst()
        return String(first).uppercased() + rest
    }
}

extension Target {
    enum TargetType: String {
        case interface
        case feature
        case tests
        case testing
        case example

        var product: Product {
            switch self {
                case .interface, .feature, .testing: .framework
                case .tests: .unitTests
                case .example: .app
            }
        }

        func targetName(_ name: String) -> String {
            return "\(name)\(rawValue.firstCharacterUppercased)"
        }

        func bundleId(name: String) -> String {
            return "com.sangwon.\(name).\(rawValue)"
        }

        var targetSources: SourceFilesList {
            switch self {
                case .feature: "Sources/**"
                default: "\(rawValue.firstCharacterUppercased)/**"
            }
        }

        func targetDependencies(name: String, additionalDependencies: [TargetDependency] = []) -> [TargetDependency] {
            let baseDependencies: [TargetDependency]
            switch self {
                case .interface: baseDependencies = []
                case .feature: baseDependencies = [.target(name: TargetType.interface.targetName(name))]
                case .tests: baseDependencies = [.target(name: TargetType.feature.targetName(name)),
                                                 .target(name: TargetType.testing.targetName(name))]
                case .testing: baseDependencies = [.target(name: TargetType.interface.targetName(name))]
                case .example: baseDependencies = [.target(name: TargetType.feature.targetName(name)),
                                                   .target(name: TargetType.testing.targetName(name))]
            }
            return baseDependencies + additionalDependencies
        }
    }

    static func target(name: String, type: TargetType, dependencies: [TargetDependency] = []) -> Target {
        return .target(
            name: type.targetName(name),
            destinations: .iOS,
            product: type.product,
            bundleId: type.bundleId(name: name),
            deploymentTargets: .iOS("16.0"),
            sources: type.targetSources,
            dependencies: type.targetDependencies(name: name, additionalDependencies: dependencies)
        )
    }
}

extension Project {
    static func module(
        name: String,
        dependencies: [Target.TargetType: [TargetDependency]] = [:]
    ) -> Project {
        let targets: [Target] = [
            .target(name: name, type: .interface, dependencies: dependencies[.interface] ?? []),
            .target(name: name, type: .feature, dependencies: dependencies[.feature] ?? []),
            .target(name: name, type: .tests, dependencies: dependencies[.tests] ?? []),
            .target(name: name, type: .testing, dependencies: dependencies[.testing] ?? []),
            .target(name: name, type: .example, dependencies: dependencies[.example] ?? []),
        ]
        return Project(name: name, targets: targets)
    }
}
