import UIKit

// MARK: - Layout Manager

final class LayoutManager {
    private var configuration = WheelPickerConfiguration()
    
    func updateConfiguration(_ config: WheelPickerConfiguration) {
        configuration = config
    }
    
    func layoutScrollView(_ scrollView: UIView, in bounds: CGRect) {
        scrollView.pin.all()
    }
    
    // MARK: - Calculation Methods
    
    func calculateSideMargin(scrollViewWidth: CGFloat, itemWidth: CGFloat) -> CGFloat {
        return (scrollViewWidth - itemWidth)/2
    }
    
    func calculateTotalWidth(itemCount: Int, itemWidth: CGFloat, spacing: CGFloat) -> CGFloat {
        guard itemCount > 0 else { return 0 }
        return CGFloat(itemCount) * itemWidth + CGFloat(max(0, itemCount - 1)) * spacing
    }
    
    func calculateContainerWidth(itemCount: Int, itemWidth: CGFloat, spacing: CGFloat, scrollViewWidth: CGFloat) -> CGFloat {
        let totalWidth = calculateTotalWidth(itemCount: itemCount, itemWidth: itemWidth, spacing: spacing)
        let sideMargin = calculateSideMargin(scrollViewWidth: scrollViewWidth, itemWidth: itemWidth)
        return totalWidth + sideMargin * 2
    }
    
    func calculateItemXPosition(index: Int, itemWidth: CGFloat, spacing: CGFloat, scrollViewWidth: CGFloat) -> CGFloat {
        let sideMargin = calculateSideMargin(scrollViewWidth: scrollViewWidth, itemWidth: itemWidth)
        return sideMargin + CGFloat(index) * (itemWidth + spacing)
    }
    
    func calculateTargetOffset(index: Int, itemWidth: CGFloat, spacing: CGFloat) -> CGFloat {
        return CGFloat(index) * (itemWidth + spacing)
    }
    
    func calculateItemDistance(index: Int, centerX: CGFloat, itemWidth: CGFloat,
                               spacing: CGFloat, scrollOffset: CGFloat, scrollViewWidth: CGFloat) -> CGFloat
    {
        let sideMargin = calculateSideMargin(scrollViewWidth: scrollViewWidth, itemWidth: itemWidth)
        let itemOffset = sideMargin - scrollOffset
        let itemCenter = itemOffset + CGFloat(index) * (itemWidth + spacing) + itemWidth/2
        return abs(itemCenter - centerX)
    }
    
    func calculateSelectedIndex(from contentOffset: CGFloat, itemWidth: CGFloat,
                                spacing: CGFloat, itemCount: Int) -> Int
    {
        let index = Int(round(contentOffset/(itemWidth + spacing)))
        return max(0, min(index, itemCount - 1))
    }
}
