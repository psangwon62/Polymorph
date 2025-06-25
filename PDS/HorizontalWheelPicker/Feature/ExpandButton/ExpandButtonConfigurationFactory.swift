import Foundation

enum ExpandButtonConfigurationFactory {
    private static let configurations: [Position: ExpandButtonConfiguration] = [
        .bottom: BottomExpandButtonConfiguration(),
        .top: TopExpandButtonConfiguration(),
        .left: LeftExpandButtonConfiguration(),
        .right: RightExpandButtonConfiguration()
    ]

    static func configuration(for position: Position) -> ExpandButtonConfiguration {
        guard let configuration = configurations[position] else {
            assertionFailure("No configuration found for position: \(position)")
            return BottomExpandButtonConfiguration()
        }
        return configuration
    }
}
