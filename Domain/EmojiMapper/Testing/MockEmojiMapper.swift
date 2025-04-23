import Foundation
import EmojiMapperInterface
import UIKit

public struct MockEmojiMapper: EmojiMapper {
    public func mapEmojis(for colors: [[UIColor]]) -> [[String]] {
        return [[]]
    }
    
    // Mock implementation
}
