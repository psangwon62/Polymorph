import ProjectDescription

let project = Project(
    name: "Logger",
    targets: [
        .target(
            name: "LoggerInterface",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.sangwon.polymorph.loggerinterface",
            sources: ["Interface/**"]
        ),
        .target(
            name: "Logger",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.sangwon.polymorph.logger",
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
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "Logger"),
            ]
        ),
    ],
    fileHeaderTemplate: nil
)
