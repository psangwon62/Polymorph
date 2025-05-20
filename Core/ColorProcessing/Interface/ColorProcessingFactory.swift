import UIKit

public protocol ColorProcessingFactory {
    func createLUT() -> any LUT<UIColor, CIELAB>
    func createConverter(cache: (any Cache<UIColor, CIELAB>)?) -> ColorConverter
    func createComparator(cache: (any Cache<UIColor, UIColor>)?) -> ColorComparator
    func createCache<Key: Hashable, V>() -> any Cache<Key, V>
}
