import Foundation

struct PathMultipliers {
    let tipDeparture: (horizontal: CGFloat, vertical: CGFloat)
    let mainDeparture: (horizontal: CGFloat, vertical: CGFloat)
    
    static let `default` = PathMultipliers(
        tipDeparture: (1, 1),
        mainDeparture: (1, 1)
    )
}
