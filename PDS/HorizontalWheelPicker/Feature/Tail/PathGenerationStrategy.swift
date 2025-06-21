import UIKit

enum PathElement {
    case line(Point)
    case curve(CurveSegmentInfo)
}

// MARK: - Curve Segment Info

struct CurveSegmentInfo {
    let to: Point
    let control1: Point
    let control2: Point
}

// MARK: - Path Strategy Factory

enum PathStrategyFactory {
    private static let strategies: [TailPosition: PathGenerationStrategy] = [
        .bottom: BottomPathStrategy(),
        .top: TopPathStrategy(),
        .left: LeftPathStrategy(),
        .right: RightPathStrategy()
    ]

    static func strategy(for position: TailPosition) -> PathGenerationStrategy {
        strategies[position]!
    }
}

// MARK: - Path Generation Strategy

protocol PathGenerationStrategy {
    func generatePath(size: Size, configuration: TailConfiguration) -> UIBezierPath
    func pathElements(size: Size, configuration: TailConfiguration) -> [PathElement]
}

// MARK: - Base Path Strategy (공통 로직)

class BasePathStrategy: PathGenerationStrategy {
    func generatePath(size: Size, configuration: TailConfiguration) -> UIBezierPath {
        let path = UIBezierPath()
        let startPoint = getStartPoint(configuration.startPoint, w: size.width, h: size.height)
        path.move(to: startPoint.cgPoint)

        for element in pathElements(size: size, configuration: configuration) {
            switch element {
            case .line(let to):
                path.addLine(to: to.cgPoint)
            case .curve(let segment):
                path.addCurve(
                    to: segment.to.cgPoint,
                    controlPoint1: segment.control1.cgPoint,
                    controlPoint2: segment.control2.cgPoint
                )
            }
        }

        path.close()
        return path
    }

    func pathElements(size: Size, configuration: any TailConfiguration) -> [PathElement] {
        []
    }

    private func getStartPoint(_ type: StartPointType, w: CGFloat, h: CGFloat) -> Point {
        switch type {
        case .zero: return Point.zero
        case .topCenter: return Point.topCenter(width: w)
        case .bottomCenter: return Point.bottomCenter(width: w, height: h)
        case .leftCenter: return Point.leftCenter(height: h)
        case .rightCenter: return Point.rightCenter(width: w, height: h)
        }
    }

    func centerPoint(_ type: TailPosition, size: Size) -> Point {
        let w = size.width, h = size.height
        switch type {
        case .bottom: return Point.bottomCenter(width: w, height: h)
        case .top: return Point.topCenter(width: w)
        case .left: return Point.leftCenter(height: h)
        case .right: return Point.rightCenter(width: w, height: h)
        }
    }

    func getControlPoint(_ ratio: (x: Double, y: Double), size: Size) -> Point {
        return Point(size.width * ratio.x, size.height * ratio.y)
    }
}

extension PathElement {
    static func tipDepartureCurve(
        center: Point,
        configuration: TailConfiguration,
        horizontalMultiplier: CGFloat = 1,
        verticalMultiplier: CGFloat = 1
    ) -> PathElement {
        let tip = configuration.tipConfiguration

        return .curve(CurveSegmentInfo(
            to: center + Point(tip.radius * horizontalMultiplier * tip.mainOffset.horizontal, tip.radius * verticalMultiplier * tip.mainOffset.vertical),
            control1: center + Point(tip.radius * tip.controlOffset1.horizontal, tip.radius * tip.controlOffset1.vertical),
            control2: center + Point(tip.radius * tip.controlOffset2.horizontal, tip.radius * tip.controlOffset2.vertical)
        ))
    }

    static func mainBodyApproachCurve(configuration: TailConfiguration, size: Size) -> PathElement {
        let main = configuration.mainCurve
        return .curve(CurveSegmentInfo(
            to: configuration.lineStartPoint(for: size),
            control1: getControlPoint(main.entry1, size: size),
            control2: getControlPoint(main.exit1, size: size)
        ))
    }

    static func mainBodyDepartureCurve(
        center: Point,
        configuration: TailConfiguration,
        size: Size,
        horizontalMultiplier: CGFloat = 1,
        verticalMultiplier: CGFloat = 1
    ) -> PathElement {
        let tip = configuration.tipConfiguration
        let main = configuration.mainCurve

        return .curve(CurveSegmentInfo(
            to: center + Point(tip.radius * horizontalMultiplier * tip.mainOffset.horizontal, tip.radius * verticalMultiplier * tip.mainOffset.vertical),
            control1: getControlPoint(main.entry2, size: size),
            control2: getControlPoint(main.exit2, size: size)
        ))
    }

    static func tipClosureCurve(center: Point, configuration: TailConfiguration, controlAdjustment: ((TipConfiguration) -> (Point, Point))? = nil) -> PathElement {
        let tip = configuration.tipConfiguration

        let (control1, control2): (Point, Point)
        if let adjustment = controlAdjustment {
            (control1, control2) = adjustment(tip)
        } else {
            control1 = center + Point(tip.radius * -tip.controlOffset2.horizontal, tip.radius * tip.controlOffset2.vertical)
            control2 = center + Point(tip.radius * -tip.controlOffset1.horizontal, tip.radius * tip.controlOffset1.vertical)
        }

        return .curve(CurveSegmentInfo(
            to: center,
            control1: control1,
            control2: control2
        ))
    }

    static func bodyEdgeLine(configuration: TailConfiguration, size: Size) -> PathElement {
        return .line(configuration.lineEndPoint(for: size))
    }

    static func getControlPoint(_ ratio: (x: Double, y: Double), size: Size) -> Point {
        return Point(size.width * ratio.x, size.height * ratio.y)
    }
}

// MARK: - Concrete Strategies

class BottomPathStrategy: BasePathStrategy {
    override func pathElements(size: Size, configuration: TailConfiguration) -> [PathElement] {
        let center = centerPoint(configuration.position, size: size)

        return [
            .tipDepartureCurve(center: center, configuration: configuration),
            .mainBodyApproachCurve(configuration: configuration, size: size),
            .bodyEdgeLine(configuration: configuration, size: size),
            .mainBodyDepartureCurve(center: center, configuration: configuration, size: size, horizontalMultiplier: -1),
            .tipClosureCurve(center: center, configuration: configuration)
        ]
    }
}

class TopPathStrategy: BasePathStrategy {
    override func pathElements(size: Size, configuration: TailConfiguration) -> [PathElement] {
        let center = centerPoint(configuration.position, size: size)

        return [
            .tipDepartureCurve(center: center, configuration: configuration),
            .mainBodyApproachCurve(configuration: configuration, size: size),
            .bodyEdgeLine(configuration: configuration, size: size),
            .mainBodyDepartureCurve(center: center, configuration: configuration, size: size, horizontalMultiplier: -1),
            .tipClosureCurve(center: center, configuration: configuration)
        ]
    }
}

class LeftPathStrategy: BasePathStrategy {
    override func pathElements(size: Size, configuration: TailConfiguration) -> [PathElement] {
        let center = centerPoint(configuration.position, size: size)

        return [
            .tipDepartureCurve(center: center, configuration: configuration, verticalMultiplier: -1),
            .mainBodyApproachCurve(configuration: configuration, size: size),
            .bodyEdgeLine(configuration: configuration, size: size),
            .mainBodyDepartureCurve(center: center, configuration: configuration, size: size),
            .tipClosureCurve(center: center, configuration: configuration) { tip in
                let control1 = center + Point(tip.radius * tip.controlOffset2.horizontal, tip.radius * tip.mainOffset.vertical)
                let control2 = center + Point(tip.radius * tip.controlOffset1.horizontal, tip.radius * -tip.controlOffset1.vertical)
                return (control1, control2)
            }
        ]
    }
}

class RightPathStrategy: BasePathStrategy {
    override func pathElements(size: Size, configuration: TailConfiguration) -> [PathElement] {
        let center = centerPoint(configuration.position, size: size)

        return [
            .tipDepartureCurve(center: center, configuration: configuration),
            .mainBodyApproachCurve(configuration: configuration, size: size),
            .line(configuration.lineEndPoint(for: size)),
            .mainBodyDepartureCurve(center: center, configuration: configuration, size: size, verticalMultiplier: -1),
            .tipClosureCurve(center: center, configuration: configuration) { tip in
                let control1 = center + Point(tip.radius * tip.controlOffset2.horizontal, tip.radius * -tip.mainOffset.vertical)
                let control2 = center + Point(tip.radius * tip.controlOffset1.horizontal, tip.radius * tip.controlOffset1.vertical)
                return (control1, control2)
            }
        ]
    }
}
