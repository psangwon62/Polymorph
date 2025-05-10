import Foundation

public struct CIEXYZ: Hashable {
    public var X: CGFloat
    public var Y: CGFloat
    public var Z: CGFloat
    
    public init(X: CGFloat, Y: CGFloat, Z: CGFloat) {
        self.X = X
        self.Y = Y
        self.Z = Z
    }
}
