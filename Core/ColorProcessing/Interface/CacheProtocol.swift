import Foundation

public protocol CacheProtocol<Key, Value> {
    associatedtype Key: Hashable
    associatedtype Value
    var maxCacheSize: Int { get }
    func get(for key: Key, compute: (Key) -> Value) -> Value
    func clear()
    func store(key: Key, value: Value)
    func updateAccessOrder(for key: Key)
}
