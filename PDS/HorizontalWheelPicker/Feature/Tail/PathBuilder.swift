import Foundation

struct PathBuilder {
    private let size: Size
    private let configuration: TailConfiguration
    
    init(size: Size, configuration: TailConfiguration) {
        self.size = size
        self.configuration = configuration
    }
    
    func buildElements() -> [PathElement] {
        let center = configuration.startPoint(for: size)
        
        return [
            buildTipDeparture(center: center),
            buildMainApproach(),
            buildBodyEdge(),
            buildMainDeparture(center: center),
            buildTipClosure(center: center)
        ]
    }
    
    private func buildTipDeparture(center: Point) -> PathElement {
        let tip = configuration.tipConfig
        let multipliers = configuration.multipliers.tipDeparture
        
        return .curve(.init(
            to: center + Point(
                tip.radius * multipliers.horizontal * tip.mainOffset.x,
                tip.radius * multipliers.vertical * tip.mainOffset.y
            ),
            control1: center + Point(
                tip.radius * tip.controlOffset1.x,
                tip.radius * tip.controlOffset1.y
            ),
            control2: center + Point(
                tip.radius * tip.controlOffset2.x,
                tip.radius * tip.controlOffset2.y
            )
        ))
    }
    
    private func buildMainApproach() -> PathElement {
        let main = configuration.mainCurveConfig
        return .curve(.init(
            to: configuration.lineStartPoint(for: size),
            control1: controlPoint(main.approachEntry),
            control2: controlPoint(main.approachExit)
        ))
    }
    
    private func buildBodyEdge() -> PathElement {
        .line(configuration.lineEndPoint(for: size))
    }
    
    private func buildMainDeparture(center: Point) -> PathElement {
        let tip = configuration.tipConfig
        let main = configuration.mainCurveConfig
        let multipliers = configuration.multipliers.mainDeparture
    
        return .curve(.init(
            to: center + Point(
                tip.radius * multipliers.horizontal * tip.mainOffset.x,
                tip.radius * multipliers.vertical * tip.mainOffset.y
            ),
            control1: controlPoint(main.departureEntry),
            control2: controlPoint(main.departureExit)
        ))
    }
    
    private func buildTipClosure(center: Point) -> PathElement {
        let tip = configuration.tipConfig
        
        let (control1, control2): (Point, Point)
        if let customClosure = configuration.customTipClosure {
            (control1, control2) = customClosure(center, tip)
        } else {
            control1 = center + Point(
                tip.radius * -tip.controlOffset2.x,
                tip.radius * tip.controlOffset2.y
            )
            control2 = center + Point(
                tip.radius * -tip.controlOffset1.x,
                tip.radius * tip.controlOffset1.y
            )
        }
        
        return .curve(.init(to: center, control1: control1, control2: control2))
    }
    
    private func controlPoint(_ offset: Point) -> Point {
        Point(size.width * offset.x, size.height * offset.y)
    }
}
