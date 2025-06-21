import UIKit

// MARK: - Configuration Protocol

protocol TailConfiguration {
    var position: TailPosition { get }
    var tipConfig: TipConfiguration { get }
    var mainCurveConfig: MainCurveConfiguration { get }
    var multipliers: PathMultipliers { get }
    var customTipClosure: ((Point, TipConfiguration) -> (Point, Point))? { get }

    func startPoint(for size: Size) -> Point
    func lineStartPoint(for size: Size) -> Point
    func lineEndPoint(for size: Size) -> Point
}

extension TailConfiguration {
    var customTipClosure: ((Point, TipConfiguration) -> (Point, Point))? { nil }
    func startPoint(for size: Size) -> Point {
        let width = size.width, height = size.height
        
        return switch position {
        case .bottom: Point.bottomCenter(width: width, height: height)
        case .top: Point.topCenter(width: width)
        case .left: Point.leftCenter(height: height)
        case .right: Point.rightCenter(width: width, height: height)
        }
    }
}

// MARK: - Concrete Configuration

// MARK: - Bottom Tail Configuration

struct BottomTailConfiguration: TailConfiguration {
    let position: TailPosition = .bottom
    
    let tipConfig = TipConfiguration(
        mainOffset: (0.8, -0.5),
        controlOffset1: (0.6, -0.2),
        controlOffset2: (0.2, -0.05)
    )
    
    let mainCurveConfig = MainCurveConfiguration(
        approachEntry: (0.68, 0.7),
        approachExit: (0.85, 0.1),
        departureEntry: (0.15, 0.1),
        departureExit: (0.32, 0.7)
    )
    
    let multipliers = PathMultipliers(
        tipDeparture: (1, 1),
        mainDeparture: (-1, 1)
    )

    func lineStartPoint(for size: Size) -> Point {
        Point(size.width, 0)
    }
    
    func lineEndPoint(for size: Size) -> Point {
        Point(0, 0)
    }
}

// MARK: - Top Tail Configuration

struct TopTailConfiguration: TailConfiguration {
    let position: TailPosition = .top
    
    let tipConfig = TipConfiguration(
        mainOffset: (0.8, 0.5),
        controlOffset1: (0.2, 0.05),
        controlOffset2: (0.6, 0.2)
    )
    
    let mainCurveConfig = MainCurveConfiguration(
        approachEntry: (0.68, 0.3),
        approachExit: (0.85, 0.9),
        departureEntry: (0.15, 0.9),
        departureExit: (0.32, 0.3)
    )
    
    let multipliers = PathMultipliers(
        tipDeparture: (1, 1),
        mainDeparture: (-1, 1)
    )
    
    func lineStartPoint(for size: Size) -> Point {
        Point(size.width, size.height)
    }
    
    func lineEndPoint(for size: Size) -> Point {
        Point(0, size.height)
    }
}

// MARK: - Left Tail Configuration

struct LeftTailConfiguration: TailConfiguration {
    let position: TailPosition = .left
    
    let tipConfig = TipConfiguration(
        mainOffset: (0.5, 0.8),
        controlOffset1: (0.05, -0.2),
        controlOffset2: (0.2, -0.6)
    )
    
    let mainCurveConfig = MainCurveConfiguration(
        approachEntry: (0.3, 0.32),
        approachExit: (0.9, 0.15),
        departureEntry: (0.9, 0.85),
        departureExit: (0.3, 0.68)
    )
    
    let multipliers = PathMultipliers(
        tipDeparture: (1, -1),
        mainDeparture: (1, 1)
    )
    
    let customTipClosure: ((Point, TipConfiguration) -> (Point, Point))? = { center, tip in
        let control1 = center + Point(tip.radius * tip.controlOffset2.x, tip.radius * tip.mainOffset.y)
        let control2 = center + Point(tip.radius * tip.controlOffset1.x, tip.radius * -tip.controlOffset1.y)
        return (control1, control2)
    }

    func lineStartPoint(for size: Size) -> Point {
        Point(size.width, 0)
    }
    
    func lineEndPoint(for size: Size) -> Point {
        Point(size.width, size.height)
    }
}

// MARK: - Right Tail Configuration

struct RightTailConfiguration: TailConfiguration {
    let position: TailPosition = .right
    
    let tipConfig = TipConfiguration(
        mainOffset: (-0.5, 0.8),
        controlOffset1: (-0.05, 0.2),
        controlOffset2: (-0.2, 0.6)
    )
    
    let mainCurveConfig = MainCurveConfiguration(
        approachEntry: (0.7, 0.68),
        approachExit: (0.1, 0.85),
        departureEntry: (0.1, 0.15),
        departureExit: (0.7, 0.32)
    )
    
    let multipliers = PathMultipliers(
        tipDeparture: (1, 1),
        mainDeparture: (1, -1)
    )
    
    let customTipClosure: ((Point, TipConfiguration) -> (Point, Point))? = { center, tip in
        let control1 = center + Point(tip.radius * tip.controlOffset2.x, tip.radius * -tip.mainOffset.y)
        let control2 = center + Point(tip.radius * tip.controlOffset1.x, tip.radius * tip.controlOffset1.y)
        return (control1, control2)
    }

    func lineStartPoint(for size: Size) -> Point {
        Point(0, size.height)
    }
    
    func lineEndPoint(for size: Size) -> Point {
        Point(0, 0)
    }
}
