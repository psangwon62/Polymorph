import Foundation

// MARK: - Core Types

public enum TailPosition: CaseIterable {
    case bottom, top, left, right
}

// MARK: - Geometry Primitives

struct Point {
    let x: CGFloat
    let y: CGFloat
    
    init(_ x: CGFloat, _ y: CGFloat) {
        self.x = x
        self.y = y
    }
    
    var cgPoint: CGPoint { CGPoint(x: x, y: y) }
    
    static let zero = Point(0, 0)
    
    static func + (lhs: Point, rhs: Point) -> Point {
        Point(lhs.x + rhs.x, lhs.y + rhs.y)
    }
    
    static func * (point: Point, scalar: CGFloat) -> Point {
        Point(point.x * scalar, point.y * scalar)
    }
    
    static func center(width: CGFloat, height: CGFloat) -> Point {
        Point(width / 2, height / 2)
    }
    
    static func topCenter(width: CGFloat) -> Point {
        Point(width / 2, 0)
    }
    
    static func bottomCenter(width: CGFloat, height: CGFloat) -> Point {
        Point(width / 2, height)
    }
    
    static func leftCenter(height: CGFloat) -> Point {
        Point(0, height / 2)
    }
    
    static func rightCenter(width: CGFloat, height: CGFloat) -> Point {
        Point(width, height / 2)
    }
}

struct Size {
    let width: CGFloat
    let height: CGFloat
    
    var swapped: Size { Size(width: height, height: width) }
    var cgSize: CGSize { CGSize(width: width, height: height) }
}
