import Foundation

public protocol LUT<Key, Value> {
    associatedtype Key: Hashable
    associatedtype Value
    func get(for key: Key) -> Value?
    func clear()
    func getAll() -> [Key: Value]
}
