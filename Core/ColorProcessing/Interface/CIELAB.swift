import Foundation

public struct CIELAB: Hashable {
    public var L: CGFloat
    public var a: CGFloat
    public var b: CGFloat

    public init(L: CGFloat, a: CGFloat, b: CGFloat) {
        self.L = L
        self.a = a
        self.b = b
    }
}
