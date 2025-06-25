import Foundation

struct TailPathMultipliers {
    let tipDeparture: (horizontal: CGFloat, vertical: CGFloat)
    let mainDeparture: (horizontal: CGFloat, vertical: CGFloat)
    
    static let `default` = TailPathMultipliers(
        tipDeparture: (1, 1),
        mainDeparture: (1, 1)
    )
}
