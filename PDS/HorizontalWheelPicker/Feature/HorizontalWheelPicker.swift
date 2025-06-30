import ReactorKit
import RxCocoa
import RxSwift
import UIKit

// MARK: - Main Component

public final class HorizontalWheelPicker: UIView, View {
    public var disposeBag = DisposeBag()

    // MARK: - Constants

    enum Constants {
        static let cornerRadius: CGFloat = 12
        static let selectionIndicatorBorderWidth: CGFloat = 2
        static let selectionIndicatorCornerRadius: CGFloat = 8
        static let animationDuration: TimeInterval = 0.2
        static let baseDecelerationRate: CGFloat = 0.4
        static let velocityThreshold: CGFloat = 0.8
        static let maxDecelerationRate: CGFloat = 1.2
        static let centerProximityThreshold: CGFloat = 1.0 / 3.0
        static let maxScaleBoost: CGFloat = 0.2
        static let minScale: CGFloat = 0.7
        static let minOpacity: CGFloat = 0.3
    }

    // MARK: - Public Properties

    public var configuration = WheelPickerConfiguration() {
        didSet { applyConfiguration() }
    }

    // MARK: - Private Properties

    private let scrollView = UIScrollView()
    private let containerView = UIView()
    private let selectionIndicator = UIView()
    private let tailView = UIView()
    private let expandButton = UIButton()

    private var itemLabels: [UILabel] = []
    private var items: [String] = []
    private var selectedIndex: Int = 0

    private lazy var hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    private lazy var layoutManager = LayoutManager()
    private lazy var visualEffectsManager = VisualEffectsManager()
    private lazy var scrollPhysicsManager = ScrollPhysicsManager()

    private var itemSelectedSubject = PublishSubject<Int>()
    public var rx_itemSelected: Observable<Int> { itemSelectedSubject.asObservable() }

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
        setupView()
        setupScrollView()
        setupSelectionIndicator()
        setupTail()
        setupExpandButton()
        setupHierarchy()
        applyConfiguration()
    }

    private func setupView() {
        backgroundColor = .clear
    }

    private func setupScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.decelerationRate = .fast
        scrollView.bounces = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.backgroundColor = dynamicBackgroundColor
        scrollView.layer.cornerRadius = Constants.cornerRadius
    }

    private func setupSelectionIndicator() {
        selectionIndicator.layer.borderWidth = Constants.selectionIndicatorBorderWidth
        selectionIndicator.layer.cornerRadius = Constants.selectionIndicatorCornerRadius
        selectionIndicator.backgroundColor = .clear
        selectionIndicator.isUserInteractionEnabled = false
    }

    private func setupTail() {
        tailView.backgroundColor = dynamicBackgroundColor
    }

    private func setupExpandButton() {
        expandButton.backgroundColor = dynamicBackgroundColor
        expandButton.setImage(.init(systemName: "ellipsis"), for: .normal)
        expandButton.tintColor = .secondaryLabel
        expandButton.addAction(.init { [weak self] _ in
            // ReactorKit 액션으로 처리할 수 있도록 별도 바인딩 필요
        }, for: .touchUpInside)
    }

    private func setupHierarchy() {
        addSubview(scrollView)
        addSubview(selectionIndicator)
        addSubview(tailView)
        addSubview(expandButton)
        scrollView.addSubview(containerView)
    }

    // MARK: - Configuration

    private func applyConfiguration() {
        updateSelectionIndicatorAppearance()
        updateLayoutManagerConfiguration()
        invalidateLayout()
    }

    private func updateSelectionIndicatorAppearance() {
        selectionIndicator.layer.borderColor = configuration.selectionIndicatorColor.cgColor
    }

    private func updateLayoutManagerConfiguration() {
        layoutManager.updateConfiguration(configuration)
    }

    private func invalidateLayout() {
        setNeedsLayout()
        updateItemAppearance()
    }

    // MARK: - Layout

    override public func layoutSubviews() {
        super.layoutSubviews()

        layoutScrollView()
        layoutSelectionIndicator()
        layoutTail()
        layoutExpandButton()
        layoutContent()
    }

    private func layoutScrollView() {
        layoutManager.layoutScrollView(scrollView, in: bounds)
    }

    private func layoutSelectionIndicator() {
        layoutManager.layoutSelectionIndicator(selectionIndicator, relativeTo: scrollView)
    }

    private func layoutTail() {
        layoutManager.layoutTail(tailView, relativeTo: scrollView)
    }

    private func layoutExpandButton() {
        layoutManager.layoutExpandButton(expandButton, relativeTo: scrollView)
    }

    private func layoutContent() {
        layoutContainer()
        layoutItemLabels()
        updateScrollViewContentSize()
    }

    private func layoutContainer() {
        layoutManager.layoutContainer(containerView, itemCount: items.count, in: scrollView.bounds)
    }

    private func layoutItemLabels() {
        guard !itemLabels.isEmpty else { return }

        itemLabels.enumerated().forEach { index, label in
            layoutManager.layoutItemLabels(label, at: index, in: scrollView.bounds)
        }
    }

    private func updateScrollViewContentSize() {
        layoutManager.updateScrollViewContentSize(scrollView, itemCount: items.count, in: scrollView.bounds)
    }

    // MARK: - Calculate Methods

    private func calculateContainerWidth() -> CGFloat {
        return layoutManager.calculateContainerWidth(
            itemCount: items.count,
            itemWidth: configuration.itemWidth,
            spacing: configuration.itemSpacing,
            scrollViewWidth: scrollView.bounds.width
        )
    }

    private func calculateItemDistance(for index: Int, centerX: CGFloat) -> CGFloat {
        return layoutManager.calculateItemDistance(
            index: index,
            centerX: centerX,
            itemWidth: configuration.itemWidth,
            spacing: configuration.itemSpacing,
            scrollOffset: scrollView.contentOffset.x,
            scrollViewWidth: scrollView.bounds.width
        )
    }

    private func calculateRealTimeEffects(for distance: CGFloat) -> VisualEffects {
        return visualEffectsManager.calculateEffects(
            distance: distance,
            itemWidth: configuration.itemWidth,
            selectedColor: configuration.selectedTextColor,
            deselectedColor: configuration.deselectedTextColor
        )
    }

    private func calculateStaticEffect(for index: Int, isSelected: Bool) -> VisualEffects {
        return visualEffectsManager.calculateStaticEffects(
            isSelected: isSelected,
            distance: CGFloat(abs(index - selectedIndex)),
            selectedColor: configuration.selectedTextColor,
            deselectedColor: configuration.deselectedTextColor
        )
    }

    // MARK: - ReactorKit 바인딩

    public func bind(reactor: HorizontalWheelPickerReactor) {
        // 아이템 목록 바인딩
        reactor.state.map { $0.items }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                self?.setItemsRx(items)
            })
            .disposed(by: disposeBag)
        // 선택 인덱스 바인딩
        reactor.state.map { $0.selectedIndex }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                self?.setSelectedIndexRx(index)
            })
            .disposed(by: disposeBag)
        // 아이템 선택 이벤트 → 액션 전달
        rx_itemSelected
            .map { HorizontalWheelPickerReactor.Action.selectItem($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        // (필요시) expandButton 등 추가 액션 바인딩
    }

    // MARK: - Rx 상태 적용

    private func setItemsRx(_ items: [String]) {
        self.items = items
        recreateItemLabels()
        setNeedsLayout()
        layoutIfNeeded()
        updateItemAppearanceRealTime()
    }

    private func setSelectedIndexRx(_ index: Int) {
        guard isValidIndex(index) else { return }
        if !scrollView.isTracking && !scrollView.isDecelerating {
            scrollToIndex(index, animated: true)
            selectedIndex = index
            updateItemAppearance()
            if configuration.enableHapticFeedback {
                hapticGenerator.impactOccurred()
            }
        } else {
            // 스크롤 중에는 selectedIndex만 갱신하고, 실시간 효과만 적용
            selectedIndex = index
            updateItemAppearanceRealTime()
        }
    }

    // MARK: - Private Methods

    private func recreateItemLabels() {
        clearExistingLables()

        itemLabels = items.map { text in
            createNewLabels(with: text)
        }
    }

    private func clearExistingLables() {
        itemLabels.forEach { $0.removeFromSuperview() }
        itemLabels.removeAll()
    }

    private func createNewLabels(with text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = configuration.font
        label.textAlignment = .center
        containerView.addSubview(label)
        return label
    }

    // MARK: - Appearance Updates

    private func updateItemAppearanceRealTime() {
        let centerX = scrollView.bounds.width / 2

        itemLabels.enumerated().forEach { index, label in
            let distance = calculateItemDistance(for: index, centerX: centerX)
            let effects = calculateRealTimeEffects(for: distance)
            applyRealTimeEffects(to: label, effects: effects)
        }
    }

    private func updateItemAppearance() {
        itemLabels.enumerated().forEach { index, label in
            let isSelected = index == selectedIndex
            let effects = calculateStaticEffect(for: index, isSelected: isSelected)
            animateEffects(to: label, effects: effects)
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

    // MARK: - Visual Effects

    private func applyRealTimeEffects(to label: UILabel, effects: VisualEffects) {
        visualEffectsManager.applyRealTimeEffects(to: label, effects: effects)
    }

    private func animateEffects(to label: UILabel, effects: VisualEffects) {
        visualEffectsManager.animateEffects(to: label, effects: effects)
    }

    // MARK: - Validation

    private func isValidIndex(_ index: Int) -> Bool {
        return items.indices.contains(index)
    }

    private func clampIndex(_ index: Int) -> Int {
        return max(0, min(index, items.count - 1))
    }
}

// MARK: - UIScrollViewDelegate

extension HorizontalWheelPicker: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateItemAppearanceRealTime()
        let newIndex = layoutManager.calculateSelectedIndex(
            from: scrollView.contentOffset.x,
            itemWidth: configuration.itemWidth,
            spacing: configuration.itemSpacing,
            itemCount: items.count
        )
        if newIndex != selectedIndex {
            selectedIndex = newIndex
            if configuration.enableHapticFeedback {
                hapticGenerator.impactOccurred()
            }
            itemSelectedSubject.onNext(selectedIndex)
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
    }

    public func scrollViewDidEndDecelerating(_: UIScrollView) {
        updateItemAppearance()
    }

    public func scrollViewDidEndScrollingAnimation(_: UIScrollView) {
        updateItemAppearance()
    }
}
