import Foundation

public enum DownscaleOption {
    case x1 // 원본 크기 (다운스케일 없음)
    case x4 // 1/4 크기 (폭/높이 각각 1/2)
    case x16 // 1/16 크기 (폭/높이 각각 1/4)
    case x64 // 1/64 크기 (폭/높이 각각 1/8)

    public var scaleFactor: CGFloat {
        switch self {
            case .x1: return 1.0
            case .x4: return 0.5
            case .x16: return 0.25
            case .x64: return 0.125
        }
    }
}
