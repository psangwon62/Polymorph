import ColorProcessingInterface
import UIKit
import LoggerInterface

public class ComparatorCache {
    private var cache: [UIColor: UIColor] = [:]
    private var accessOrder: [UIColor] = []
    private let maxCacheSize: Int
    private let lock = NSLock()
    private let logger: Logger?

    public init(maxCacheSize: Int = 1000, logger: Logger? = nil) {
        self.maxCacheSize = maxCacheSize
        self.logger = logger
        logger?.debug("Comparator Cache initialized")
    }
    
    /// Get closest color from input UIColor and cache
    /// - Parameters:
    ///   - color: Input color
    ///   - compute: Computing closure, returns closest UIColor
    /// - Returns: Closest UIColor from Input
    public func getClosestColor(for color: UIColor, compute: (UIColor) -> UIColor) -> UIColor {
        lock.lock()
        defer { lock.unlock() }
        logger?.debug("Get Closest Color for \(color)")
        if let cached = cache[color] {
            logger?.debug("Found Cache, update access order")
            updateAccessOrder(for: color)
            return cached
        }
        
        logger?.debug("Can't find Cache, compute")
        let closest = compute(color)
        logger?.debug("Computed: \(closest)")
        store(input: color, output: closest)
        return closest
    }
    
    /// Clear Comparator cache
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        logger?.debug("Clear Comparator Cache")
        cache.removeAll()
        accessOrder.removeAll()
    }
    
    /// Cache computed color
    /// - Parameters:
    ///   - input: Input UIColor
    ///   - output: Closest UIColor(GRC mostly)
    private func store(input: UIColor, output: UIColor) {
        logger?.debug("Store cache \(input): \(output)")
        if cache.count >= maxCacheSize, let oldest = accessOrder.first {
            logger?.debug("Cache is full, remove oldest: \(oldest)")
            cache.removeValue(forKey: oldest)
            accessOrder.removeFirst()
        }
        cache[input] = output
        accessOrder.append(input)
        logger?.debug("Cache updated: \(cache)")
    }
    
    /// Update access order(LRU Cache)
    /// - Parameter color: Recently used Color
    private func updateAccessOrder(for color: UIColor) {
        logger?.debug("Update access order for \(color)")
        if let index = accessOrder.firstIndex(of: color) {
            accessOrder.remove(at: index)
            accessOrder.append(color)
        }
    }
}
