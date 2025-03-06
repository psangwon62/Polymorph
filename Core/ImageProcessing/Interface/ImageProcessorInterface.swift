import UIKit

public protocol ImageProcessorInterface {
    func extractColors(from image: UIImage) -> [[UIColor]]
}
    