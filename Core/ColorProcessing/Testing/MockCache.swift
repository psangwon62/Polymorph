import ColorProcessingInterface
import UIKit

public actor MockCache<Key: Hashable, Value>: CacheProtocol {
    public var stubbedValue: Value?
    public var getCallCount = 0
    public var storeCallCount = 0
    public var clearCallCount = 0
    public var lastGetKey: Key?
    public var lastStoredKey: Key?
    public var lastStoredValue: Value?
    public var computeCallCount = 0
    public var maxCacheSize: Int = 100
    
    public init() {}

    public func get(for key: Key, compute: (Key) async -> Value) async -> Value {
        getCallCount += 1
        lastGetKey = key
        if let value = stubbedValue {
            return value
        }
        computeCallCount += 1
        return await compute(key)
    }

    public func store(key: Key, value: Value) {
        storeCallCount += 1
        lastStoredKey = key
        lastStoredValue = value
        stubbedValue = value
    }

    public func clear() {
        clearCallCount += 1
        stubbedValue = nil
        lastStoredKey = nil
        lastStoredValue = nil
    }
    
    public func updateAccessOrder(for key: Key) {
        
    }
}
