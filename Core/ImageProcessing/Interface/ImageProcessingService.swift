import UIKit

public protocol ImageProcessingService {
    func processImage(_ input: Data) -> [[UIColor]]?
}
