import ColorProcessingInterface
import LoggerInterface
import UIKit

public class DefaultColorProcessingFactory: ColorProcessingFactory {
    private let logger: Logger?

    public init(logger: Logger? = nil) {
        self.logger = logger
    }

    public func createLUT() -> any LUT<UIColor, CIELAB> {
        GRC64LUT(logger: logger)
    }

    public func createConverter(cache: (any Cache<UIColor, CIELAB>)? = nil) -> ColorConverter {
        let lut = createLUT()
        let cache = cache ?? createCache()
        return DefaultColorConverter(lut: lut, cache: cache, logger: logger)
    }

    public func createComparator(cache: (any Cache<UIColor, UIColor>)? = nil) -> ColorComparator {
        let lut = createLUT()
        let cache = cache ?? createCache()
        let converter = createConverter()
        return DefaultColorComparator(converter: converter, lut: lut, cache: cache, logger: logger)
    }

    public func createCache<Key: Hashable, Value>() -> any Cache<Key, Value> {
        GenericCache<Key, Value>(logger: logger)
    }
}
