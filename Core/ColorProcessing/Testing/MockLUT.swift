import ColorProcessingInterface
import UIKit

public class MockLUT: LUT {
    public typealias Key = UIColor
    public typealias Value = CIELAB

    public var stubbedColors: [UIColor: CIELAB] = [:]
    public var lastGetKey: UIColor?

    public init() {}

    public func get(for key: UIColor) -> CIELAB? {
        lastGetKey = key
        return stubbedColors[key]
    }

    public func getAll() -> [UIColor: CIELAB] {
        return stubbedColors
    }
}
