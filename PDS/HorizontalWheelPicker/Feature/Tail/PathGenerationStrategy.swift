import UIKit

// MARK: - Path Generation Strategy Protocol

protocol PathGenerationStrategy {
    func generatePath(size: Size, configuration: TailConfiguration) -> UIBezierPath
}

// MARK: - Concrete Path Generation Strategy

struct UnifiedPathStrategy: PathGenerationStrategy {
    func generatePath(size: Size, configuration: TailConfiguration) -> UIBezierPath {
        precondition(size.width > 0 && size.height > 0, "Size must be positive")

        let path = UIBezierPath()
        let startPoint = configuration.startPoint(for: size)
        path.move(to: startPoint.cgPoint)

        let builder = PathBuilder(size: size, configuration: configuration)
        let elements = builder.buildElements()

        for element in elements {
            switch element {
            case .line(let to):
                path.addLine(to: to.cgPoint)
            case .curve(let curve):
                path.addCurve(
                    to: curve.to.cgPoint,
                    controlPoint1: curve.control1.cgPoint,
                    controlPoint2: curve.control2.cgPoint
                )
            }
        }

        path.close()
        return path
    }
}

enum PathStrategyFactory {
    static func strategy(for position: TailPosition) -> PathGenerationStrategy {
        return UnifiedPathStrategy()
    }
}
