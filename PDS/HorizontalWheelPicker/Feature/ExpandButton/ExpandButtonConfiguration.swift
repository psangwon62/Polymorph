import Foundation

protocol Configuration {
    var position: Position { get }
    func startPoint(for size: Size) -> Point
}

//protocol ExpandButtonConfiguration: Configuration {
//    var position: Position { get }
//    var curveIntensity: CGFloat { get }
//    func startPoint(for size: Size) -> Point
//}
//
//extension ExpandButtonConfiguration {
//    var curveIntensity: CGFloat { 0.25 }
//
//    func startPoint(for size: Size) -> Point {
//        let width = size.width, height = size.height
//        return switch position {
//        case .bottom:
//            Point.topRight(width: width)
//        case .top:
//            Point.bottomLeft(height: height)
//        case .left:
//            Point.bottomLeft(height: height)
//        case .right:
//            Point.zero
//        }
//    }
//}
//
//struct BottomExpandButtonConfiguration: ExpandButtonConfiguration {
//    var position: Position = .bottom
//}
//
//struct TopExpandButtonConfiguration: ExpandButtonConfiguration {
//    var position: Position = .top
//}
//
//struct LeftExpandButtonConfiguration: ExpandButtonConfiguration {
//    var position: Position = .left
//}
//
//struct RightExpandButtonConfiguration: ExpandButtonConfiguration {
//    var position: Position = .right
//}
protocol ExpandButtonConfiguration: Configuration {
    var position: Position { get }
    var curveIntensity: CGFloat { get }
    var multipliers: ExpandButtonMultipliers { get }
    func startPoint(for size: Size) -> Point
}

extension ExpandButtonConfiguration {
    var curveIntensity: CGFloat { 0.25 }

    func startPoint(for size: Size) -> Point {
        let width = size.width, height = size.height
        return switch position {
        case .bottom:
            Point.topRight(width: width)
        case .top:
            Point.bottomLeft(height: height)
        case .left:
            Point.bottomLeft(height: height)
        case .right:
            Point.topRight(width: width)
        }
    }
}

// MARK: - Multipliers Structure

struct ExpandButtonMultipliers {
    let firstCurve: CurveMultipliers
    let straightLine: LineMultipliers
    let secondCurve: CurveMultipliers
    
    struct CurveMultipliers {
        let horizontal: CGFloat
        let vertical: CGFloat
        let controlRatio: CGFloat
    }
    
    struct LineMultipliers {
        let horizontal: CGFloat
        let vertical: CGFloat
    }
}

// MARK: - Concrete Configurations

struct BottomExpandButtonConfiguration: ExpandButtonConfiguration {
    var position: Position = .bottom
    
    var multipliers: ExpandButtonMultipliers {
        ExpandButtonMultipliers(
            firstCurve: .init(horizontal: 1, vertical: 0, controlRatio: 0.5),
            straightLine: .init(horizontal: 1, vertical: 0),
            secondCurve: .init(horizontal: 1, vertical: 1, controlRatio: 0.5)
        )
    }
}

struct TopExpandButtonConfiguration: ExpandButtonConfiguration {
    var position: Position = .top
    
    var multipliers: ExpandButtonMultipliers {
        ExpandButtonMultipliers(
            firstCurve: .init(horizontal: 1, vertical: 1, controlRatio: 0.5),
            straightLine: .init(horizontal: 1, vertical: 1),
            secondCurve: .init(horizontal: 1, vertical: 0, controlRatio: 0.5)
        )
    }
}

struct LeftExpandButtonConfiguration: ExpandButtonConfiguration {
    var position: Position = .left
    
    var multipliers: ExpandButtonMultipliers {
        ExpandButtonMultipliers(
            firstCurve: .init(horizontal: 0, vertical: 1, controlRatio: 0.5),
            straightLine: .init(horizontal: 0, vertical: 1),
            secondCurve: .init(horizontal: 1, vertical: 1, controlRatio: 0.5)
        )
    }
}

struct RightExpandButtonConfiguration: ExpandButtonConfiguration {
    var position: Position = .right
    
    var multipliers: ExpandButtonMultipliers {
        ExpandButtonMultipliers(
            firstCurve: .init(horizontal: 1, vertical: 1, controlRatio: 0.5),
            straightLine: .init(horizontal: 1, vertical: 1),
            secondCurve: .init(horizontal: 0, vertical: 1, controlRatio: 0.5)
        )
    }
}
