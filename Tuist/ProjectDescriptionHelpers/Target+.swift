import ProjectDescription

public extension Target {
    enum TargetType: String, CaseIterable {
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
            switch self {
                case .feature: return name
                default:
                    return "\(name)\(rawValue.firstCharacterUppercased)"
            }
        }

        func bundleId(name: String) -> String {
            return "com.sangwon.\(name).\(rawValue)"
        }

        var targetSources: SourceFilesList {
            return "\(rawValue.firstCharacterUppercased)/**"
        }

        func targetDependencies(name: String, additionalDependencies: [TargetDependency] = []) -> [TargetDependency] {
            let baseDependencies: [TargetDependency]
            switch self {
                case .interface: baseDependencies = []
                case .feature: baseDependencies = .target(name: name, types: [.interface])
                case .tests: baseDependencies = .target(name: name, types: [.feature, .testing])
                case .testing: baseDependencies = .target(name: name, types: [.interface])
                case .example: baseDependencies = .target(name: name, types: [.feature, .testing])
            }
            return baseDependencies + additionalDependencies
        }
    }

    static func target(name: String, type: TargetType, dependencies: [TargetDependency] = []) -> Target {
        var target = Target.target(
            name: type.targetName(name),
            destinations: .iOS,
            product: type.product,
            bundleId: type.bundleId(name: name),
            deploymentTargets: .iOS("16.0"),
            sources: type.targetSources,
            dependencies: type.targetDependencies(name: name, additionalDependencies: dependencies)
        )
        if type == .example {
            target.infoPlist = .extendingDefault(with: [
                "UILaunchScreen": "",
            ])
        }
        return target
    }
}

private extension String {
    var firstCharacterUppercased: String {
        guard let first = first else {
            return ""
        }
        let rest = dropFirst()
        return String(first).uppercased() + rest
    }
}

extension [TargetDependency] {
    static func target(name: String, types: [Target.TargetType] = []) -> Self {
        types.compactMap { .target(name: $0.targetName(name)) }
    }
}
