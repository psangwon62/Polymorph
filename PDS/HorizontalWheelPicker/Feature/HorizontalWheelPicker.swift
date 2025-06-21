import PinLayout
import UIKit

// MARK: - Delegate

public protocol HorizontalWheelPickerDelegate: AnyObject {
    func wheelPicker(_ picker: HorizontalWheelPicker, didSelectItemAt index: Int)
}

// MARK: - Main Component

public final class HorizontalWheelPicker: UIView {
    // MARK: - Constants
    
    enum Constants {
        static let cornerRadius: CGFloat = 12
        static let selectionIndicatorBorderWidth: CGFloat = 2
        static let selectionIndicatorCornerRadius: CGFloat = 8
        static let animationDuration: TimeInterval = 0.2
        static let baseDecelerationRate: CGFloat = 0.4
        static let velocityThreshold: CGFloat = 0.8
        static let maxDecelerationRate: CGFloat = 1.2
        static let centerProximityThreshold: CGFloat = 1.0/3.0
        static let maxScaleBoost: CGFloat = 0.2
        static let minScale: CGFloat = 0.7
        static let minOpacity: CGFloat = 0.3
    }
    
    // MARK: - Public Properties
    
    public weak var delegate: HorizontalWheelPickerDelegate?
    
    public var configuration = WheelPickerConfiguration() {
        didSet { applyConfiguration() }
    }
    
    // MARK: - Private Properties
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    private let selectionIndicator = UIView()
    private let tailView = UIView()
    
    private var itemLabels: [UILabel] = []
    private var items: [String] = []
    private var selectedIndex: Int = 0
    
    private lazy var hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    private lazy var layoutManager = LayoutManager()
    private lazy var visualEffectsManager = VisualEffectsManager()
    private lazy var scrollPhysicsManager = ScrollPhysicsManager()
    
    // MARK: - Computed Properties
    
    private var dynamicBackgroundColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor.systemGray6.withAlphaComponent(0.7)
                default:
                    return UIColor.systemGray6.withAlphaComponent(0.5)
                }
            }
        } else {
            return UIColor.systemGray6.withAlphaComponent(0.5)
        }
    }
    
    // MARK: - Initialization
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        setupAppearance()
        setupScrollView()
        setupSelectionIndicator()
        setupTail()
        setupHierarchy()
        applyConfiguration()
    }
    
    private func setupAppearance() {
        backgroundColor = dynamicBackgroundColor
        layer.cornerRadius = Constants.cornerRadius
    }
    
    private func setupScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.decelerationRate = .fast
        scrollView.bounces = true
        scrollView.alwaysBounceHorizontal = true
    }
    
    private func setupSelectionIndicator() {
        selectionIndicator.layer.borderWidth = Constants.selectionIndicatorBorderWidth
        selectionIndicator.layer.cornerRadius = Constants.selectionIndicatorCornerRadius
        selectionIndicator.backgroundColor = .clear
        selectionIndicator.isUserInteractionEnabled = false
    }
    
    private func setupTail() {
        tailView.backgroundColor = backgroundColor
    }
    
    private func setupHierarchy() {
        addSubview(scrollView)
        addSubview(selectionIndicator)
        addSubview(tailView)
        scrollView.addSubview(containerView)
    }
    
    private func applyConfiguration() {
        selectionIndicator.layer.borderColor = configuration.selectionIndicatorColor.cgColor
        layoutManager.updateConfiguration(configuration)
        setNeedsLayout()
        updateItemAppearance()
    }
    
    // MARK: - Layout
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        layoutManager.layoutScrollView(scrollView, in: bounds)
        
        selectionIndicator.pin
            .center(to: scrollView.anchor.center)
            .size(CGSize(width: configuration.itemWidth, height: configuration.itemHeight))
        
        let tailManager = TailManager(position: configuration.tailPosition, size: configuration.tailSize)
        tailManager.layoutTail(tailView, relativeTo: scrollView)
        
        layoutContainerAndItems()
        TailManager.updateMask(for: tailView,
                               position: configuration.tailPosition,
                               size: configuration.tailSize)
    }
    
    private func layoutContainerAndItems() {
        let containerWidth = layoutManager.calculateContainerWidth(
            itemCount: items.count,
            itemWidth: configuration.itemWidth,
            spacing: configuration.itemSpacing,
            scrollViewWidth: scrollView.bounds.width
        )
        
        containerView.pin
            .top()
            .left()
            .width(containerWidth)
            .height(scrollView.bounds.height)
        
        layoutItemLabels()
        updateScrollViewContentSize()
    }
    
    private func layoutItemLabels() {
        guard !itemLabels.isEmpty else { return }
        
        itemLabels.enumerated().forEach { index, label in
            let xPosition = layoutManager.calculateItemXPosition(
                index: index,
                itemWidth: configuration.itemWidth,
                spacing: configuration.itemSpacing,
                scrollViewWidth: scrollView.bounds.width
            )
            
            label.pin
                .left(xPosition)
                .vCenter()
                .size(CGSize(width: configuration.itemWidth, height: configuration.itemHeight))
        }
    }
    
    private func updateScrollViewContentSize() {
        let containerWidth = layoutManager.calculateContainerWidth(
            itemCount: items.count,
            itemWidth: configuration.itemWidth,
            spacing: configuration.itemSpacing,
            scrollViewWidth: scrollView.bounds.width
        )
        scrollView.contentSize = CGSize(width: containerWidth, height: scrollView.bounds.height)
    }
    
    // MARK: - Dark Mode Support
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *),
           traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)
        {
            backgroundColor = dynamicBackgroundColor
            tailView.backgroundColor = backgroundColor
        }
    }
    
    // MARK: - Public Methods
    
    public func configure(with items: [String], selectedIndex: Int = 0) {
        self.items = items
        self.selectedIndex = max(0, min(selectedIndex, items.count - 1))
        
        recreateItemLabels()
        setNeedsLayout()
        layoutIfNeeded()
        
        updateItemAppearanceRealTime()
        scrollToIndex(self.selectedIndex, animated: false)
    }
    
    public func selectItem(at index: Int, animated: Bool = true) {
        guard items.indices.contains(index) else { return }
        
        selectedIndex = index
        scrollToIndex(index, animated: animated)
        updateItemAppearance()
        delegate?.wheelPicker(self, didSelectItemAt: index)
        
        if configuration.enableHapticFeedback {
            hapticGenerator.impactOccurred()
        }
    }
    
    // MARK: - Private Methods
    
    private func recreateItemLabels() {
        itemLabels.forEach { $0.removeFromSuperview() }
        itemLabels.removeAll()
        
        itemLabels = items.map { text in
            let label = UILabel()
            label.text = text
            label.font = configuration.font
            label.textAlignment = .center
            containerView.addSubview(label)
            return label
        }
    }
    
    private func updateItemAppearanceRealTime() {
        let centerX = scrollView.bounds.width/2
        
        itemLabels.enumerated().forEach { index, label in
            let distance = layoutManager.calculateItemDistance(
                index: index,
                centerX: centerX,
                itemWidth: configuration.itemWidth,
                spacing: configuration.itemSpacing,
                scrollOffset: scrollView.contentOffset.x,
                scrollViewWidth: scrollView.bounds.width
            )
            
            let effects = visualEffectsManager.calculateEffects(
                distance: distance,
                itemWidth: configuration.itemWidth,
                selectedColor: configuration.selectedTextColor,
                deselectedColor: configuration.deselectedTextColor
            )
            
            visualEffectsManager.applyRealTimeEffects(to: label, effects: effects)
        }
    }
    
    private func updateItemAppearance() {
        itemLabels.enumerated().forEach { index, label in
            let isSelected = index == selectedIndex
            let effects = visualEffectsManager.calculateStaticEffects(
                isSelected: isSelected,
                distance: CGFloat(abs(index - selectedIndex)),
                selectedColor: configuration.selectedTextColor,
                deselectedColor: configuration.deselectedTextColor
            )
            visualEffectsManager.animateEffects(to: label, effects: effects)
        }
    }
    
    private func calculateSelectedIndex(from contentOffset: CGFloat) -> Int {
        return layoutManager.calculateSelectedIndex(
            from: contentOffset,
            itemWidth: configuration.itemWidth,
            spacing: configuration.itemSpacing,
            itemCount: items.count
        )
    }
    
    private func scrollToIndex(_ index: Int, animated: Bool) {
        let targetOffset = layoutManager.calculateTargetOffset(
            index: index,
            itemWidth: configuration.itemWidth,
            spacing: configuration.itemSpacing
        )
        scrollView.setContentOffset(CGPoint(x: targetOffset, y: 0), animated: animated)
    }
}

// MARK: - UIScrollViewDelegate

extension HorizontalWheelPicker: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateItemAppearanceRealTime()
        
        let newIndex = calculateSelectedIndex(from: scrollView.contentOffset.x)
        
        if newIndex != selectedIndex {
            selectedIndex = newIndex
            if configuration.enableHapticFeedback {
                hapticGenerator.impactOccurred()
            }
            delegate?.wheelPicker(self, didSelectItemAt: selectedIndex)
        }
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                          withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        let targetIndex = scrollPhysicsManager.calculateTargetIndex(
            currentOffset: scrollView.contentOffset.x,
            velocity: velocity.x,
            itemWidth: configuration.itemWidth,
            spacing: configuration.itemSpacing,
            itemCount: items.count
        )
        
        let targetOffset = layoutManager.calculateTargetOffset(
            index: targetIndex,
            itemWidth: configuration.itemWidth,
            spacing: configuration.itemSpacing
        )
        
        targetContentOffset.pointee = CGPoint(x: targetOffset, y: 0)
        
        if targetIndex != selectedIndex {
            selectedIndex = targetIndex
            if configuration.enableHapticFeedback {
                hapticGenerator.impactOccurred()
            }
            delegate?.wheelPicker(self, didSelectItemAt: selectedIndex)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateItemAppearance()
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateItemAppearance()
    }
}
