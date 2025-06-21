import Foundation

enum PathElement {
    case line(Point)
    case curve(CurveTo)
    
    struct CurveTo {
        let to: Point
        let control1: Point
        let control2: Point
    }
}
