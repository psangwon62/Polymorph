import UIKit

// MARK: - Configuration

public struct WheelPickerConfiguration {
    public var itemWidth: CGFloat = 60
    public var itemHeight: CGFloat = 60
    public var itemSpacing: CGFloat = 0
    public var selectedTextColor: UIColor = .label
    public var deselectedTextColor: UIColor = .secondaryLabel
    public var font: UIFont = .systemFont(ofSize: 40)
    public var selectionIndicatorColor: UIColor = .systemBlue
    public var tailPosition: Position = .bottom
    public var tailSize: CGSize = .init(width: 20, height: 10)
    public var expandButtonPosition: Position {
        tailPosition.opposite
    }
    public var expandButtonSize: CGSize = .init(width: 44, height: 8)
    public var enableHapticFeedback: Bool = true
    
    public init() {}
}
