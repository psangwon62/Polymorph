import Foundation

// MARK: - Configuration Factory

enum TailConfigurationFactory {
    private static let configurations: [TailPosition: TailConfiguration] = [
        .bottom: BottomTailConfiguration(),
        .top: TopTailConfiguration(),
        .left: LeftTailConfiguration(),
        .right: RightTailConfiguration()
    ]

    static func configuration(for position: TailPosition) -> TailConfiguration {
        configurations[position]!
    }
}
