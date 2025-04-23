import Foundation
import UIKit

public protocol EmojiMapper {
    func mapEmojis(for colors: [[UIColor]]) -> [[String]]
}
