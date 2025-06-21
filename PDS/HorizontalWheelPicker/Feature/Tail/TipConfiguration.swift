import Foundation

struct TipConfiguration {
    let radius: CGFloat
    let mainOffset: Point
    let controlOffset1: Point
    let controlOffset2: Point
    
    init(radius: CGFloat = 3,
         mainOffset: (CGFloat, CGFloat),
         controlOffset1: (CGFloat, CGFloat),
         controlOffset2: (CGFloat, CGFloat)) {
        self.radius = radius
        self.mainOffset = Point(mainOffset.0, mainOffset.1)
        self.controlOffset1 = Point(controlOffset1.0, controlOffset1.1)
        self.controlOffset2 = Point(controlOffset2.0, controlOffset2.1)
    }
}
