import ProjectDescription

let project = Project(
    name: "Polymorph",
    targets: [
        .target(
            name: "Polymorph",
            destinations: .iOS,
            product: .app,
            bundleId: "com.sangwon.polymorph",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .project(target: "Emojis", path: .relativeToRoot("Domain/Emojis")),
                .project(target: "Logger", path: .relativeToRoot("Shared/Logger")),
                .external(name: "ReactorKit"),
                .external(name: "RxSwift"),
            ]
        ),
        .target(
            name: "PolymorphTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.sangwon.polymorphtests",
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "Polymorph")]
        ),
    ],
    fileHeaderTemplate: ""
)
