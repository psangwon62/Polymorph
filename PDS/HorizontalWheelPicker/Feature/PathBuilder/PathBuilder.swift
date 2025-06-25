import Foundation

struct PathBuilder {
    private let size: Size
    private let tailConfiguration: TailConfiguration?
    private let expandButtonConfiguration: ExpandButtonConfiguration?
    
    init(size: Size, tailConfiguration: TailConfiguration) {
        self.size = size
        self.tailConfiguration = tailConfiguration
        self.expandButtonConfiguration = nil
    }
    
    init(size: Size, expandButtonConfiguration: ExpandButtonConfiguration) {
        self.size = size
        self.expandButtonConfiguration = expandButtonConfiguration
        self.tailConfiguration = nil
    }
    
    func tailElements() -> [PathElement] {
        guard let configuration = tailConfiguration else {
            assertionFailure()
            return []
        }
        let startPoint = configuration.startPoint(for: size)
        
        return [
            buildTipDeparture(with: startPoint),
            buildMainApproach(),
            buildBodyEdge(),
            buildMainDeparture(with: startPoint),
            buildTipClosure(with: startPoint)
        ]
    }

    func expandButtonElements() -> [PathElement] {
        guard let configuration = expandButtonConfiguration else {
            assertionFailure()
            return []
        }
        let start = configuration.startPoint(for: size)
        
        return [
            bodyDeparture(with: start),
            line(with: start),
            bodyArrival(with: start)
        ]
    }
}

// MARK: - Expand Button Path Build Methods

extension PathBuilder {
    private func bodyDeparture(with start: Point) -> PathElement {
        guard let configuration = expandButtonConfiguration else {
            assertionFailure()
            return .line(.zero)
        }
        let width = size.width, height = size.height
        let intensity = configuration.curveIntensity
        let multipliers = configuration.direction
        
        return .curve(.init(
            to: start + Point(
                width * intensity * multipliers.horizontal,
                height * multipliers.vertical
            ),
            control1: start + Point(
                width * intensity * multipliers.horizontal,
                0
            ),
            control2: start + Point(
                width * intensity * multipliers.horizontal * 0.5,
                height * multipliers.vertical
            )
        ))
    }
    
    private func line(with start: Point) -> PathElement {
        guard let configuration = expandButtonConfiguration else {
            assertionFailure()
            return .line(.zero)
        }
        let width = size.width, height = size.height
        let multipliers = configuration.direction
        let lineStartPoint = configuration.lineStartPoint
        
        return .line(start + Point(
            width * lineStartPoint * multipliers.horizontal,
            height * multipliers.vertical
        ))
    }
    
    private func bodyArrival(with start: Point) -> PathElement {
        guard let configuration = expandButtonConfiguration else {
            assertionFailure()
            return .line(.zero)
        }
        let width = size.width, height = size.height
        let intensity = configuration.curveIntensity
        let multipliers = configuration.direction
        let lineStartPoint = configuration.lineStartPoint
        
        return .curve(.init(
            to: start + Point(
                width * multipliers.horizontal,
                0
            ),
            control1: start + Point(
                width * (1 - intensity * 0.5) * multipliers.horizontal,
                height * multipliers.vertical
            ),
            control2: start + Point(
                width * lineStartPoint * multipliers.horizontal,
                0
            )
        ))
    }
}

// MARK: - Tail Path Build Methods

extension PathBuilder {
    private func buildTipDeparture(with start: Point) -> PathElement {
        guard let configuration = tailConfiguration else {
            assertionFailure()
            return .line(.zero)
        }
        
        let tip = configuration.tipConfig
        let multipliers = configuration.multipliers.tipDeparture
        
        return .curve(.init(
            to: start + Point(
                tip.radius * multipliers.horizontal * tip.mainOffset.x,
                tip.radius * multipliers.vertical * tip.mainOffset.y
            ),
            control1: start + Point(
                tip.radius * tip.controlOffset1.x,
                tip.radius * tip.controlOffset1.y
            ),
            control2: start + Point(
                tip.radius * tip.controlOffset2.x,
                tip.radius * tip.controlOffset2.y
            )
        ))
    }
    
    private func buildMainApproach() -> PathElement {
        guard let configuration = tailConfiguration else {
            assertionFailure()
            return .line(.zero)
        }
        
        let main = configuration.mainCurveConfig
        return .curve(.init(
            to: configuration.lineStartPoint(for: size),
            control1: controlPoint(main.approachEntry),
            control2: controlPoint(main.approachExit)
        ))
    }
    
    private func buildBodyEdge() -> PathElement {
        guard let configuration = tailConfiguration else {
            assertionFailure()
            return .line(.zero)
        }
        
        return .line(configuration.lineEndPoint(for: size))
    }
    
    private func buildMainDeparture(with start: Point) -> PathElement {
        guard let configuration = tailConfiguration else {
            assertionFailure()
            return .line(.zero)
        }
        
        let tip = configuration.tipConfig
        let main = configuration.mainCurveConfig
        let multipliers = configuration.multipliers.mainDeparture
    
        return .curve(.init(
            to: start + Point(
                tip.radius * multipliers.horizontal * tip.mainOffset.x,
                tip.radius * multipliers.vertical * tip.mainOffset.y
            ),
            control1: controlPoint(main.departureEntry),
            control2: controlPoint(main.departureExit)
        ))
    }
    
    private func buildTipClosure(with start: Point) -> PathElement {
        guard let configuration = tailConfiguration else {
            assertionFailure()
            return .line(.zero)
        }
        
        let tip = configuration.tipConfig
        let (control1, control2): (Point, Point)
        
        if let customClosure = configuration.customTipClosure {
            (control1, control2) = customClosure(start, tip)
        } else {
            control1 = start + Point(
                tip.radius * -tip.controlOffset2.x,
                tip.radius * tip.controlOffset2.y
            )
            control2 = start + Point(
                tip.radius * -tip.controlOffset1.x,
                tip.radius * tip.controlOffset1.y
            )
        }
        
        return .curve(.init(to: start, control1: control1, control2: control2))
    }
    
    private func controlPoint(_ offset: Point) -> Point {
        Point(size.width * offset.x, size.height * offset.y)
    }
}
