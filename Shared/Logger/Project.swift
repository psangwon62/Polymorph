import ProjectDescription

let project = Project(
    name: "Logger",
    targets: [
        .target(
            name: "LoggerInterface",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.sangwon.polymorph.loggerinterface",
            deploymentTargets: .iOS("16.0"),
            sources: ["Interface/**"]
        ),
        .target(
            name: "Logger",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.sangwon.polymorph.logger",
            deploymentTargets: .iOS("16.0"),
            sources: ["Sources/**"],
            dependencies: [
                .target(name: "LoggerInterface"),
            ]
        ),
        .target(
            name: "LoggerTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.sangwon.polymorph.loggertests",
            deploymentTargets: .iOS("16.0"),
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "Logger"),
                .target(name: "LoggerInterface"),
            ]
        ),
        .target(
            name: "LoggerTesting",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.sangwon.polymorph.loggertesting",
            deploymentTargets: .iOS("16.0"),
            sources: ["Testing/**"],
            dependencies: [
                .target(name: "LoggerInterface"),
            ]
        ),
    ],
    schemes: [
        .scheme(
            name: "LoggerTests",
            testAction: .targets(["LoggerTests"])
        ),
    ],
    fileHeaderTemplate: nil
)
