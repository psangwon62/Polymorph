import EmojisInterface

public class EmojiService {
    public init() {}

    public func getEmojis() -> [Emoji] {
        return [
            Emoji(symbol: "😊", name: "Smile"),
            Emoji(symbol: "🚀", name: "Rocket"),
            Emoji(symbol: "🌟", name: "Star")
        ]
    }
}
