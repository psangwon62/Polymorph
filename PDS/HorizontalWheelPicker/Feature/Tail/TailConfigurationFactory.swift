import Foundation

enum TailConfigurationFactory {
    private static let configurations: [TailPosition: TailConfiguration] = [
        .bottom: BottomTailConfiguration(),
        .top: TopTailConfiguration(),
        .left: LeftTailConfiguration(),
        .right: RightTailConfiguration()
    ]

    static func configuration(for position: TailPosition) -> TailConfiguration {
        guard let configuration = configurations[position] else {
            assertionFailure("No configuration found for position: \(position)")
            return BottomTailConfiguration()
        }
        return configuration
    }
}
