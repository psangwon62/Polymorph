import Foundation

public enum LogMessage {
    case initialized(String)
    case deinitialized(String)
    case userActionPerformed(action: String)
    case cacheHit(key: Any)
    case cacheMiss(key: Any)
    case cacheStore(key: Any, value: Any)

    public var description: String {
        switch self {
            case let .initialized(name):
                return "\(name) initialized"
            case let .deinitialized(name):
                return "\(name) deinitialized"
            case let .userActionPerformed(action):
                return "User performed action: \(action)"
            case let .cacheHit(key):
                return "Cache hit for key: \(key)"
            case let .cacheMiss(key):
                return "Cache miss for key: \(key)"
            case let .cacheStore(key, value):
                return "Cache stored: [\(key): \(value)]"
        }
    }
}
