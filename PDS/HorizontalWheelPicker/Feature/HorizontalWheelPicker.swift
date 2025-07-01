import ReactorKit
import RxCocoa
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

    private func calculateStaticEffect(for index: Int, isSelected: Bool, selectedIndex: Int) -> VisualEffects {
        return visualEffectsManager.calculateStaticEffects(
            isSelected: isSelected,
            distance: CGFloat(abs(index - selectedIndex)),
            selectedColor: configuration.selectedTextColor,
            deselectedColor: configuration.deselectedTextColor
        )
    }

    // MARK: - ReactorKit Binding

    public func bind(reactor: HorizontalWheelPickerReactor) {
        reactor.state.map { $0.items }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                self?.setItemsRx(items)
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.selectedIndex }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                self?.setSelectedIndexRx(index)
            })
            .disposed(by: disposeBag)

        scrollView.rx.contentOffset
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                self?.updateItemAppearanceRealTime()
            })
            .compactMap { [weak self] offset -> Int? in
                guard let self = self, !self.items.isEmpty else { return nil }
                return self.layoutManager.calculateSelectedIndex(
                    from: offset.x,
                    itemWidth: self.configuration.itemWidth,
                    spacing: self.configuration.itemSpacing,
                    itemCount: self.items.count
                )
            }
            .distinctUntilChanged()
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                if self.configuration.enableHapticFeedback {
                    self.hapticGenerator.impactOccurred()
                }
            })
            .map { HorizontalWheelPickerReactor.Action.selectItem($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        scrollView.rx.willEndDragging
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                let targetIndex = self.scrollPhysicsManager.calculateTargetIndex(
                    currentOffset: self.scrollView.contentOffset.x,
                    velocity: event.velocity.x,
                    itemWidth: self.configuration.itemWidth,
                    spacing: self.configuration.itemSpacing,
                    itemCount: self.items.count
                )
                let targetOffset = self.layoutManager.calculateTargetOffset(
                    index: targetIndex,
                    itemWidth: self.configuration.itemWidth,
                    spacing: self.configuration.itemSpacing
                )
                event.targetContentOffset.pointee = CGPoint(x: targetOffset, y: 0)
            })
            .disposed(by: disposeBag)

        Observable.merge(
            scrollView.rx.didEndDecelerating.asObservable(),
            scrollView.rx.didEndScrollingAnimation.asObservable()
        )
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak self] _ in
            self?.updateItemAppearance()
        })
        .disposed(by: disposeBag)

        expandButton.rx.tap
            .map { HorizontalWheelPickerReactor.Action.expandButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    // MARK: - Rx State Application

    private func setItemsRx(_ items: [String]) {
        self.items = items
        recreateItemLabels()
        setNeedsLayout()
        layoutIfNeeded()
        if let initialIndex = reactor?.currentState.selectedIndex {
            scrollToIndex(initialIndex, animated: false)
            updateItemAppearance()
        } else {
            updateItemAppearanceRealTime()
        }
    }

    private func setSelectedIndexRx(_ index: Int) {
        guard isValidIndex(index) else { return }

        if !scrollView.isTracking && !scrollView.isDecelerating {
            scrollToIndex(index, animated: true)
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
        guard let selectedIndex = reactor?.currentState.selectedIndex else { return }

        itemLabels.enumerated().forEach { index, label in
            let isSelected = index == selectedIndex
            let effects = calculateStaticEffect(for: index, isSelected: isSelected, selectedIndex: selectedIndex)
            animateEffects(to: label, effects: effects)
        }
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
        guard !items.isEmpty else { return 0 }
        return max(0, min(index, items.count - 1))
    }
}
