import Foundation

public struct Emoji: Identifiable {
    public let id: UUID
    public let symbol: String
    public let name: String

    public init(id: UUID = UUID(), symbol: String, name: String) {
        self.id = id
        self.symbol = symbol
        self.name = name
    }
}

public protocol Emojis {
    func getEmojis() -> [Emoji]
}
