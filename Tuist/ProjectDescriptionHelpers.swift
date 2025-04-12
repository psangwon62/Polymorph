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

        func targetDependencies(name: String, dependencies: [TargetDependency] = []) -> [TargetDependency] {
            switch self {
                case .interface: return dependencies
                case .feature: return [.target(name: TargetType.interface.targetName(name))]
                case .tests: return [.target(name: TargetType.feature.targetName(name)),
                                     .target(name: TargetType.testing.targetName(name))]
                case .testing: return [.target(name: TargetType.interface.targetName(name))]
                case .example: return [.target(name: TargetType.feature.targetName(name)),
                                       .target(name: TargetType.testing.targetName(name))]
            }
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
            dependencies: type.targetDependencies(name: name, dependencies: dependencies)
        )
    }
}

extension Project {
    static func module(name: String, dependencies: [TargetDependency] = []) -> Project {
        let targets: [Target] = [
            .target(name: name, type: .interface, dependencies: dependencies),
            .target(name: name, type: .feature),
            .target(name: name, type: .tests),
            .target(name: name, type: .testing),
            .target(name: name, type: .example),
        ]
        return Project(name: name, targets: targets)
    }
}
