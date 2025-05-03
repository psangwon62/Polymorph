import Foundation
import LoggerInterface
@testable import ColorProcessingInterface

public class GenericCache<Key: Hashable, Value>: CacheProtocol {
    private var cache: [Key: Value] = [:]
    private var accessOrder: [Key] = []
    public let maxCacheSize: Int
    private let lock = NSLock()
    private let logger: Logger?

    public init(maxCacheSize: Int = 1000, logger: Logger? = nil) {
        self.maxCacheSize = maxCacheSize
        self.logger = logger
        logger?.debug("GenericCache initialized with max size: \(maxCacheSize)")
    }

    public func get(for key: Key, compute: (Key) -> Value) -> Value {
        lock.lock()
        defer { lock.unlock() }

        if let cached = cache[key] {
            logger?.debug("Cache hit for key: \(key)")
            updateAccessOrder(for: key)
            return cached
        }

        logger?.debug("Cache miss for key: \(key)")
        let value = compute(key)
        store(key: key, value: value)
        return value
    }

    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        logger?.debug("GenericCache cleared")
        cache.removeAll()
        accessOrder.removeAll()
    }

    public func store(key: Key, value: Value) {
        lock.lock()
        defer { lock.unlock() }

        if cache.count >= maxCacheSize, let oldest = accessOrder.first {
            logger?.debug("Cache full, removing oldest: \(oldest)")
            cache.removeValue(forKey: oldest)
            accessOrder.removeFirst()
        }
        cache[key] = value
        accessOrder.append(key)
        logger?.debug("Stored key: \(key) -> \(value)")
    }

    public func updateAccessOrder(for key: Key) {
        lock.lock()
        defer { lock.unlock() }

        if let index = accessOrder.firstIndex(of: key) {
            accessOrder.remove(at: index)
            accessOrder.append(key)
            logger?.debug("Updated access order for key: \(key)")
        }
    }
}
