import Foundation

struct CurveConfiguration {
    let approachEntry: Point
    let approachExit: Point
    let departureEntry: Point
    let departureExit: Point

    init(approachEntry: (Double, Double),
         approachExit: (Double, Double),
         departureEntry: (Double, Double),
         departureExit: (Double, Double))
    {
        self.approachEntry = Point(CGFloat(approachEntry.0), CGFloat(approachEntry.1))
        self.approachExit = Point(CGFloat(approachExit.0), CGFloat(approachExit.1))
        self.departureEntry = Point(CGFloat(departureEntry.0), CGFloat(departureEntry.1))
        self.departureExit = Point(CGFloat(departureExit.0), CGFloat(departureExit.1))
    }
}
