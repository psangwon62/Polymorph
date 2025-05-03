import ColorProcessingInterface
import LoggerInterface
import UIKit

/// Class that caches UIColor converted to CIELAB
public class ColorCache {
    private var cache: [UIColor: CIELAB] = [:]
    private var accessOrder: [UIColor] = []
    public let maxCacheSize: Int
    private let lock = NSLock()
    private let logger: Logger?

    public init(maxCacheSize: Int = 1000, logger: Logger? = nil) {
        self.maxCacheSize = maxCacheSize
        self.logger = logger
        logger?.debug("ColorCache initialized with max size: \(maxCacheSize)")
    }

    public func getCIELAB(for key: UIColor, compute: (UIColor) -> CIELAB) -> CIELAB {
        lock.lock()
        defer { lock.unlock() }

        if let cached = cache[key] {
            logger?.debug("Cache hit for color: \(key)")
            updateAccessOrder(for: key)
            return cached
        }

        logger?.debug("Cache miss for color: \(key)")
        let lab = compute(key)
        store(key: key, value: lab)
        return lab
    }

    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        logger?.debug("ColorCache cleared")
        cache.removeAll()
        accessOrder.removeAll()
    }

    public func store(key: UIColor, value: CIELAB) {
        lock.lock()
        defer { lock.unlock() }

        if cache.count >= maxCacheSize, let oldest = accessOrder.first {
            logger?.debug("Cache full, removing oldest: \(oldest)")
            cache.removeValue(forKey: oldest)
            accessOrder.removeFirst()
        }
        cache[key] = value
        accessOrder.append(key)
        logger?.debug("Stored color: \(key) -> \(value)")
    }

    public func updateAccessOrder(for key: UIColor) {
        lock.lock()
        defer { lock.unlock() }

        if let index = accessOrder.firstIndex(of: key) {
            accessOrder.remove(at: index)
            accessOrder.append(key)
            logger?.debug("Updated access order for color: \(key)")
        }
    }
}
