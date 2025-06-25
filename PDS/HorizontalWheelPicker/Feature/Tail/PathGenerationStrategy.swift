import UIKit

// MARK: - Path Generation Strategy Protocol

protocol PathGenerationStrategy {
    func generatePath(size: Size, configuration: Configuration) -> UIBezierPath
}

// MARK: - Concrete Path Generation Strategy

struct UnifiedPathStrategy: PathGenerationStrategy {
    func generatePath(size: Size, configuration: Configuration) -> UIBezierPath {
        if let config = configuration as? TailConfiguration {
            return generateTailPath(size: size, configuration: config)
        }
        
        if let config = configuration as? ExpandButtonConfiguration {
            return generateExpandButtonPath(size: size, configuration: config)
        }
        
        return UIBezierPath()
    }
    
    private func generateTailPath(size: Size, configuration: TailConfiguration) -> UIBezierPath {
        precondition(size.width > 0 && size.height > 0, "Size must be positive")

        let path = UIBezierPath()
        let startPoint = configuration.startPoint(for: size)
        path.move(to: startPoint.cgPoint)

        let builder = PathBuilder(size: size, tailConfiguration: configuration)
        let elements = builder.tailElements()

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

    func generateExpandButtonPath(size: Size, configuration: ExpandButtonConfiguration) -> UIBezierPath {
        precondition(size.width > 0 && size.height > 0, "Size must be positive")

        let path = UIBezierPath()
        let startPoint = configuration.startPoint(for: size)
        path.move(to: startPoint.cgPoint)

        let builder = PathBuilder(size: size, expandButtonConfiguration: configuration)
        let elements = builder.expandButtonElements()

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
    static func strategy(for position: Position) -> PathGenerationStrategy {
        return UnifiedPathStrategy()
    }
}
