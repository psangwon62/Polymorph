import UIKit

public protocol ImageProcessing {
    func extractColors(from image: UIImage, downscale: DownscaleOption) async -> [[UIColor]]
}
