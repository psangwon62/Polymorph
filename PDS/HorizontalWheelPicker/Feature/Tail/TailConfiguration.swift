import UIKit

// MARK: - Configuration Protocol

protocol TailConfiguration {
    var position: TailPosition { get }
    var mainCurve: MainCurvePoints { get }
    var tipConfiguration: TipConfiguration { get }
    var startPoint: StartPointType { get }
    var lineSegment: LineSegmentType { get }

    func lineStartPoint(for size: Size) -> Point
    func lineEndPoint(for size: Size) -> Point
}

struct MainCurvePoints {
    let entry1: (x: Double, y: Double)
    let exit1: (x: Double, y: Double)
    let entry2: (x: Double, y: Double)
    let exit2: (x: Double, y: Double)
}

struct TipConfiguration {
    let radius: CGFloat = 3
    let mainOffset: (horizontal: CGFloat, vertical: CGFloat)
    let controlOffset1: (horizontal: CGFloat, vertical: CGFloat)
    let controlOffset2: (horizontal: CGFloat, vertical: CGFloat)
}

enum StartPointType {
    case zero, topCenter, bottomCenter, leftCenter, rightCenter
}

enum LineSegmentType {
    case topHorizontal, bottomHorizontal, leftVertical, rightVertical
    case none
}

// MARK: - Concrete Configurations

struct BottomTailConfiguration: TailConfiguration {
    let position: TailPosition = .bottom
    let startPoint: StartPointType = .bottomCenter
    let lineSegment: LineSegmentType = .topHorizontal
   
    let mainCurve = MainCurvePoints(
        entry1: (0.68, 0.7), exit1: (0.85, 0.1),
        entry2: (0.15, 0.1), exit2: (0.32, 0.7)
    )

    let tipConfiguration = TipConfiguration(
        mainOffset: (0.8, -0.5),
        controlOffset1: (0.6, -0.2),
        controlOffset2: (0.2, -0.05)
    )
    
    func lineStartPoint(for size: Size) -> Point {
        return Point(size.width, 0)
    }

    func lineEndPoint(for size: Size) -> Point {
        return Point(0, 0)
    }
}

struct TopTailConfiguration: TailConfiguration {
    let position: TailPosition = .top
    let startPoint: StartPointType = .topCenter
    let lineSegment: LineSegmentType = .bottomHorizontal

    let mainCurve = MainCurvePoints(
        entry1: (0.68, 0.3), exit1: (0.85, 0.9),
        entry2: (0.15, 0.9), exit2: (0.32, 0.3)
    )

    let tipConfiguration = TipConfiguration(
        mainOffset: (0.8, 0.5),
        controlOffset1: (0.2, 0.05),
        controlOffset2: (0.6, 0.2)
    )

    func lineStartPoint(for size: Size) -> Point {
        return Point(size.width, size.height)
    }

    func lineEndPoint(for size: Size) -> Point {
        return Point(0, size.height)
    }
}

struct LeftTailConfiguration: TailConfiguration {
    let position: TailPosition = .left
    let startPoint: StartPointType = .leftCenter
    let lineSegment: LineSegmentType = .rightVertical

    let mainCurve = MainCurvePoints(
        entry1: (0.3, 0.32), exit1: (0.9, 0.15),
        entry2: (0.9, 0.85), exit2: (0.3, 0.68)
    )

    let tipConfiguration = TipConfiguration(
        mainOffset: (0.5, 0.8),
        controlOffset1: (0.05, -0.2),
        controlOffset2: (0.2, -0.6)
    )

    func lineStartPoint(for size: Size) -> Point {
        return Point(size.width, 0)
    }

    func lineEndPoint(for size: Size) -> Point {
        return Point(size.width, size.height)
    }
}

struct RightTailConfiguration: TailConfiguration {
    let position: TailPosition = .right
    let startPoint: StartPointType = .rightCenter
    let lineSegment: LineSegmentType = .leftVertical

    let mainCurve = MainCurvePoints(
        entry1: (0.7, 0.68), exit1: (0.1, 0.85),
        entry2: (0.1, 0.15), exit2: (0.7, 0.32)
    )

    let tipConfiguration = TipConfiguration(
        mainOffset: (-0.5, 0.8),
        controlOffset1: (-0.05, 0.2),
        controlOffset2: (-0.2, 0.6)
    )
    func lineStartPoint(for size: Size) -> Point {
        return Point(0, size.height)
    }

    func lineEndPoint(for size: Size) -> Point {
        return Point(0, 0)
    }
}
