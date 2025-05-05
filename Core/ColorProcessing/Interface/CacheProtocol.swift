import Foundation

public protocol CacheProtocol<Key, Value>: Sendable {
    associatedtype Key: Hashable
    associatedtype Value
    func get(for key: Key, compute: (Key) async -> Value) async -> Value
    func store(key: Key, value: Value) async
    func clear() async
}
