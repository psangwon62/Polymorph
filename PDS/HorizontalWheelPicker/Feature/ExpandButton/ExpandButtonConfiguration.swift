import Foundation

struct ExpandButtonMultipliers {
    let horizontal: CGFloat
    let vertical: CGFloat

    static let topPath = ExpandButtonMultipliers(horizontal: 1, vertical: -1)
    static let bottomPath = ExpandButtonMultipliers(horizontal: -1, vertical: 1)
    static let leftPath = ExpandButtonMultipliers(horizontal: -1, vertical: -1)
    static let rightPath = ExpandButtonMultipliers(horizontal: 1, vertical: 1)
}

protocol Configuration {
    var position: Position { get }
    func startPoint(for size: Size) -> Point
}

protocol ExpandButtonConfiguration: Configuration {
    var position: Position { get }
    var curveIntensity: CGFloat { get }
    var direction: ExpandButtonMultipliers { get }
    var lineStartPoint: CGFloat { get }

    func startPoint(for size: Size) -> Point
}

extension ExpandButtonConfiguration {
    var curveIntensity: CGFloat { 0.25 }
    var lineStartPoint: CGFloat { 1 - curveIntensity }
    
    var direction: ExpandButtonMultipliers {
        switch position {
        case .bottom: .bottomPath
        case .top: .topPath
        case .left: .leftPath
        case .right: .rightPath
        }
    }

    func startPoint(for size: Size) -> Point {
        let width = size.width, height = size.height
        return switch position {
        case .bottom:
            Point.topRight(width: width)
        case .top:
            Point.bottomLeft(height: height)
        case .left:
            Point.bottomRight(width: width, height: height)
        case .right:
            Point.zero
        }
    }
}

struct BottomExpandButtonConfiguration: ExpandButtonConfiguration {
    var position: Position = .bottom
}

struct TopExpandButtonConfiguration: ExpandButtonConfiguration {
    var position: Position = .top
}

struct LeftExpandButtonConfiguration: ExpandButtonConfiguration {
    var position: Position = .left
}

struct RightExpandButtonConfiguration: ExpandButtonConfiguration {
    var position: Position = .right
}
