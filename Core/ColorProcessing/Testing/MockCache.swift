import ColorProcessingInterface
import UIKit

public actor MockCache<Key: Hashable, Value>: Cache {
    public var stubbedValue: Value?
    public var lastGetKey: Key?
    public var lastStoredKey: Key?
    public var lastStoredValue: Value?
    public var maxCacheSize: Int = 100

    public init() {}

    public func get(for key: Key, compute: (Key) async -> Value) async -> Value {
        lastGetKey = key
        if let value = stubbedValue {
            return value
        }
        return await compute(key)
    }

    public func store(key: Key, value: Value) {
        lastStoredKey = key
        lastStoredValue = value
        stubbedValue = value
    }

    public func clear() {
        stubbedValue = nil
        lastStoredKey = nil
        lastStoredValue = nil
    }
}
