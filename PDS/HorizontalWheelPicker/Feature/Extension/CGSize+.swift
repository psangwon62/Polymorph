import Foundation

extension CGSize {
    init(with configuration: WheelPickerConfiguration) {
        self.init(width: configuration.itemWidth, height: configuration.itemHeight)
    }
}
