// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        productTypes: ["RxSwift": .framework,
                       "ReactorKit": .framework,
                       "PinLayout": .framework]
    )
#endif

let package = Package(
    name: "Polymorph",
    dependencies: [
        .package(url: "https://github.com/ReactorKit/ReactorKit.git", .upToNextMajor(from: "3.2.0")),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.9.0")),
        .package(url: "https://github.com/layoutBox/PinLayout.git", .upToNextMinor(from: "1.10.5"))
    ]
)
