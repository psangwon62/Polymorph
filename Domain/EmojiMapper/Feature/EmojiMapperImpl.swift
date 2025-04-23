import EmojiMapperInterface
import LoggerInterface
import UIKit

public struct EmojiMapperImpl: EmojiMapper {
    private var logger: LoggerInterface?

    public init(_ logger: LoggerInterface? = nil) {
        self.logger = logger
    }

    public func mapEmojis(for colors: [[UIColor]]) -> [[String]] {
        logger?.debug(colorEmojiData.keys.count)
        return [[]]
    }
}
