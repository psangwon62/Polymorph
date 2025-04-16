import EmojisInterface
import Foundation

public struct MockEmojis: Emojis {
    public func getEmojis() -> [EmojisInterface.Emoji] {
        return []
    }
}
