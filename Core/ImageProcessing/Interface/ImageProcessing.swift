import UIKit

public protocol ImageProcessing {
    func extractColors(from image: UIImage) async -> [[UIColor]]
}
