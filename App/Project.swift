import ProjectDescription

let project = Project(
    name: "Polymorph",
    targets: [
        .target(
            name: "Polymorph",
            destinations: .iOS,
            product: .app,
            bundleId: "com.sangwon.polymorph",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen.storyboard",
                    "UIApplicationSceneManifest": [
                        "UIApplicationSupportsMultipleScenes": false,
                        "UISceneConfigurations": [
                            "UIWindowSceneSessionRoleApplication": [
                                [
                                    "UISceneConfigurationName": "Default Configuration",
                                    "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate",
                                ],
                            ],
                        ],
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
