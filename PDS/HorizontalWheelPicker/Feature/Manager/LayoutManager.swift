import PinLayout
import UIKit

// MARK: - Layout Manager

final class LayoutManager {
    private var configuration = WheelPickerConfiguration()

    func updateConfiguration(_ config: WheelPickerConfiguration) {
        configuration = config
    }

    func layoutScrollView(_ scrollView: UIView, in _: CGRect) {
        let tailSize = configuration.tailSize
        let expandButtonSize = configuration.expandButtonSize
        let tailPosition = configuration.tailPosition
        
        scrollView.pin.all()
            .marginTop(tailPosition == .top ? tailSize.height : expandButtonSize.height)
            .marginBottom(tailPosition == .top ? expandButtonSize.height : tailSize.height)
    }

    func layoutSelectionIndicator(_ indicatorView: UIView, relativeTo targetView: UIView) {
        let size = CGSize(with: configuration)

        indicatorView.pin
            .center(to: targetView.anchor.center)
            .size(size)
    }

    func layoutTail(_ tailView: UIView, relativeTo targetView: UIView) {
        let tailManager = TailManager(position: configuration.tailPosition, size: configuration.tailSize)
        tailManager.layoutTail(tailView, relativeTo: targetView)

        TailManager.updateMask(for: tailView,
                               position: configuration.tailPosition,
                               size: configuration.tailSize)
    }

    func layoutExpandButton(_ buttonView: UIView, relativeTo targetView: UIView) {
        let expandButtonManager = ExpandButtonManager(position: configuration.expandButtonPosition, size: configuration.expandButtonSize)
        expandButtonManager.layoutButton(buttonView, relativeTo: targetView)
        ExpandButtonManager.updateMask(for: buttonView, position: configuration.expandButtonPosition, size: configuration.expandButtonSize)
    }

    func layoutContainer(_ containerView: UIView, itemCount: Int, in bound: CGRect) {
        let containerWidth = calculateContainerWidth(
            itemCount: itemCount,
            itemWidth: configuration.itemWidth,
            spacing: configuration.itemSpacing,
            scrollViewWidth: bound.width
        )

        containerView.pin
            .top()
            .left()
            .width(containerWidth)
            .height(bound.height)
    }

    func layoutItemLabels(_ label: UILabel, at index: Int, in bound: CGRect) {
        let xPosition = calculateItemXPosition(
            index: index,
            itemWidth: configuration.itemWidth,
            spacing: configuration.itemSpacing,
            scrollViewWidth: bound.width
        )

        label.pin
            .left(xPosition)
            .vCenter()
            .size(CGSize(with: configuration))
    }

    func updateScrollViewContentSize(_ scrollView: UIScrollView, itemCount: Int, in bound: CGRect) {
        let containerWidth = calculateContainerWidth(
            itemCount: itemCount,
            itemWidth: configuration.itemWidth,
            spacing: configuration.itemSpacing,
            scrollViewWidth: bound.width
        )
        scrollView.contentSize = CGSize(width: containerWidth, height: bound.height)
    }

    // MARK: - Calculation Methods

    func calculateSideMargin(scrollViewWidth: CGFloat, itemWidth: CGFloat) -> CGFloat {
        return (scrollViewWidth - itemWidth) / 2
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
        let itemCenter = itemOffset + CGFloat(index) * (itemWidth + spacing) + itemWidth / 2
        return abs(itemCenter - centerX)
    }

    func calculateSelectedIndex(from contentOffset: CGFloat, itemWidth: CGFloat,
                                spacing: CGFloat, itemCount: Int) -> Int
    {
        let index = Int(round(contentOffset / (itemWidth + spacing)))
        return max(0, min(index, itemCount - 1))
    }
}
