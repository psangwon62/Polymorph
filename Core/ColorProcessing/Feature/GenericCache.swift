@testable import ColorProcessingInterface
import Foundation
import LoggerInterface

public actor GenericCache<Key: Hashable, Value>: Cache {
    private var cache: [Key: Value] = [:]
    private var accessOrder: [Key] = []
    public let maxCacheSize: Int
    private let logger: Logger?

    public init(maxCacheSize: Int = 1000, logger: Logger? = nil) {
        self.maxCacheSize = maxCacheSize
        self.logger = logger
        logger?.debug(.initialized("GenericCache<\(Key.self), \(Value.self)>, MaxSize:\(maxCacheSize)"))
    }

    @discardableResult
    public func get(for key: Key, compute: (Key) async -> Value) async -> Value {
        if let cached = cache[key] {
            logger?.debug(.cacheHit(key: "\(key)"))
            updateAccessOrder(for: key)
            return cached
        }

        logger?.debug(.cacheMiss(key: "\(key)"))
        let value = await compute(key)
        store(key: key, value: value)
        return value
    }

    public func store(key: Key, value: Value) {
        if cache.count >= maxCacheSize, let oldest = accessOrder.first {
            logger?.debug("Cache full, removing oldest: \(oldest)")
            cache.removeValue(forKey: oldest)
            accessOrder.removeFirst()
        }
        cache[key] = value
        accessOrder.append(key)
        logger?.debug(.cacheStore(key: key, value: value))
    }

    public func clear() {
        logger?.debug("GenericCache<\(Key.self), \(Value.self)> cleared")
        cache.removeAll()
        accessOrder.removeAll()
    }

    private func updateAccessOrder(for key: Key) {
        if let index = accessOrder.firstIndex(of: key) {
            accessOrder.remove(at: index)
            accessOrder.append(key)
            logger?.debug("Updated access order for key: \(key)")
        }
    }

    func getAll() -> [Key: Value] {
        return cache
    }
}
