import ProjectDescription

let project = Project(
    name: "ImageProcessing",
    targets: [
        .target(
            name: "ImageProcessingInterface",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.sangwon.polymorph.imageprocessinginterface",
            deploymentTargets: .iOS("16.0"),
            sources: ["Interface/**"]
        ),
        .target(
            name: "ImageProcessing",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.sangwon.polymorph.imageprocessing",
            deploymentTargets: .iOS("16.0"),
            sources: ["Sources/**"],
            dependencies: [
                .target(name: "ImageProcessingInterface"),
            ]
        ),
        .target(
            name: "ImageProcessingTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.sangwon.polymorph.imageprocessingtests",
            deploymentTargets: .iOS("16.0"),
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "ImageProcessing"),
            ]
        ),
        .target(
            name: "ImageProcessingExample",
            destinations: .iOS,
            product: .app,
            bundleId: "com.sangwon.polymorph.imageprocessingexample",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": [:],
                "NSPhotoLibraryUsageDescription": "이미지 색상 추출을 위해 사진 접근이 필요합니다.",
            ]),
            sources: ["Example/Sources/**"],
            resources: ["Example/Resources/**"],
            dependencies: [
                .target(name: "ImageProcessing"),
            ]
        ),
    ],
    schemes: [
        .scheme(name: "ImageProcessingExample"),
        .scheme(
            name: "ImageProcessingTests",
            buildAction: .buildAction(targets: ["ImageProcessingTests"])
        ),
    ],
    fileHeaderTemplate: nil
)
