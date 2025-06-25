import UIKit

final class ExpandButtonManager {
    let position: Position
    let size: Size
    let configuration: ExpandButtonConfiguration
    let pathStrategy: PathGenerationStrategy
    
    init(position: Position, size: CGSize) {
        self.position = position
        self.size = Size(cgSize: size)
        self.configuration = ExpandButtonConfigurationFactory.configuration(for: position)
        self.pathStrategy = PathStrategyFactory.strategy(for: position)
    }
    
    public var actualSize: Size {
        switch position {
        case .bottom, .top: return size
        case .left, .right: return size.swapped
        }
    }
    
    var maskPath: UIBezierPath {
        pathStrategy.generatePath(size: actualSize, configuration: configuration)
    }
    
    func createMaskLayer() -> CAShapeLayer {
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        maskLayer.fillColor = UIColor.black.cgColor
        return maskLayer
    }
    
    func layoutButton(_ buttonView: UIView, relativeTo targetView: UIView) {
        switch position {
        case .bottom:
            buttonView.pin.below(of: targetView, aligned: .center)
                .marginTop(0)
                .size(actualSize.cgSize)
        case .top:
            buttonView.pin.above(of: targetView, aligned: .center)
                .marginBottom(0)
                .size(actualSize.cgSize)
        case .left:
            buttonView.pin.before(of: targetView, aligned: .center)
                .marginRight(0)
                .size(actualSize.cgSize)
        case .right:
            buttonView.pin.after(of: targetView, aligned: .center)
                .marginLeft(0)
                .size(actualSize.cgSize)
        }
    }
    
    static func updateMask(for buttonView: UIView, position: Position, size: CGSize) {
        let manager = ExpandButtonManager(position: position, size: size)
        buttonView.layer.mask = manager.createMaskLayer()
    }
}
