import ProjectDescription

public extension Template.Item {
    static func project(_ name: Template.Attribute) -> Self {
        .string(
            path: "\(name)/Project.swift",
            contents: """
                import ProjectDescription
                import ProjectDescriptionHelpers

                let project = Project.module(name: "\(name)")
                """
        )
    }
    
    static func interface(_ name: Template.Attribute) -> Self {
        .string(
            path: "\(name)/Interface/\(name).swift",
            contents: """
                import Foundation

                public protocol \(name) {
                    // Define interface here
                }
                """
        )
    }

    static func feature(_ name: Template.Attribute) -> Self {
        .string(
            path: "\(name)/Feature/\(name)Impl.swift",
            contents: """
                import Foundation
                import \(name)Interface

                public struct \(name)Impl: \(name) {
                    // Implementation here
                }
                """
        )
    }

    static func tests(_ name: Template.Attribute) -> Self {
        .string(
            path: "\(name)/Tests/\(name)Tests.swift",
            contents: """
                import XCTest
                @testable import \(name)

                final class \(name)Tests: XCTestCase {
                    func testExample() {
                        XCTAssertTrue(true)
                    }
                }
                """
        )
    }

    static func testing(_ name: Template.Attribute) -> Self {
        .string(
            path: "\(name)/Testing/Mock\(name).swift",
            contents: """
                import Foundation
                import \(name)Interface

                public struct Mock\(name): \(name) {
                    // Mock implementation
                }
                """
        )
    }

    static func example(_ name: Template.Attribute) -> Self {
        .string(
            path: "\(name)/Example/Sources/\(name)ExampleApp.swift",
            contents: """
                import SwiftUI

                @main
                struct \(name)ExampleApp: App {
                    var body: some Scene {
                        WindowGroup {
                            Text("Hello, world!")
                        }
                    }
                }
                """
        )
    }
}
