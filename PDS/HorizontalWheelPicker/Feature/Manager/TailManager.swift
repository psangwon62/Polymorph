import UIKit

// MARK: - Main Tail Manager

final class TailManager {
    let position: TailPosition
    let size: Size
    let configuration: TailConfiguration
    let pathStrategy: PathGenerationStrategy
    
    init(position: TailPosition, size: CGSize) {
        self.position = position
        self.size = Size(cgSize: size)
        self.configuration = TailConfigurationFactory.configuration(for: position)
        self.pathStrategy = PathStrategyFactory.strategy(for: position)
    }
    
    public var actualSize: Size {
        switch position {
        case .bottom, .top: return size
        case .left, .right: return size.swapped
        }
    }
    
    var tailPath: UIBezierPath {
        pathStrategy.generatePath(size: size, configuration: configuration)
    }
    
    func createMaskLayer() -> CAShapeLayer {
        let maskLayer = CAShapeLayer()
        maskLayer.path = tailPath.cgPath
        maskLayer.fillColor = UIColor.black.cgColor
        return maskLayer
    }

    func layoutTail(_ tailView: UIView, relativeTo targetView: UIView) {
        switch position {
        case .bottom:
            tailView.pin.below(of: targetView, aligned: .center)
                .marginTop(0)
                .size(actualSize.cgSize)
        case .top:
            tailView.pin.above(of: targetView, aligned: .center)
                .marginBottom(0)
                .size(actualSize.cgSize)
        case .left:
            tailView.pin.before(of: targetView, aligned: .center)
                .marginRight(0)
                .size(actualSize.cgSize)
        case .right:
            tailView.pin.after(of: targetView, aligned: .center)
                .marginLeft(0)
                .size(actualSize.cgSize)
        }
    }
    
    static func updateMask(for tailView: UIView, position: TailPosition, size: CGSize) {
        let manager = TailManager(position: position, size: size)
        tailView.layer.mask = manager.createMaskLayer()
    }
}
