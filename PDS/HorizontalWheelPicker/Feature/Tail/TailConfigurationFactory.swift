import Foundation

enum TailConfigurationFactory {
    private static let configurations: [Position: TailConfiguration] = [
        .bottom: BottomTailConfiguration(),
        .top: TopTailConfiguration(),
        .left: LeftTailConfiguration(),
        .right: RightTailConfiguration()
    ]

    static func configuration(for position: Position) -> TailConfiguration {
        guard let configuration = configurations[position] else {
            assertionFailure("No configuration found for position: \(position)")
            return BottomTailConfiguration()
        }
        return configuration
    }
}
