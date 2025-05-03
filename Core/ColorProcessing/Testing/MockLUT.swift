import ColorProcessingInterface
import UIKit

public class MockLUT: LUT {
    public typealias Key = UIColor
    public typealias Value = CIELAB

    public var stubbedColors: [UIColor: CIELAB] = [:]
    public var getCallCount = 0
    public var getAllCallCount = 0
    public var clearCallCount = 0
    public var lastGetKey: UIColor?

    public init() {}

    public func get(for key: UIColor) -> CIELAB? {
        getCallCount += 1
        lastGetKey = key
        return stubbedColors[key]
    }

    public func getAll() -> [UIColor: CIELAB] {
        getAllCallCount += 1
        return stubbedColors
    }

    public func clear() {
        clearCallCount += 1
        stubbedColors.removeAll()
    }
}
