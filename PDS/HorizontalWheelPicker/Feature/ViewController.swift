import UIKit

public class ViewController: UIViewController {
    private let wheelPicker = HorizontalWheelPicker()
    private let resultLabel = UILabel()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWheelPicker()
        view.backgroundColor = .systemBlue
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        resultLabel.text = "Selected: 😎"
        resultLabel.font = .systemFont(ofSize: 24, weight: .medium)
        resultLabel.textAlignment = .center
        
        view.addSubview(resultLabel)
        view.addSubview(wheelPicker)
    }
    
    private func layoutViews() {
        resultLabel.pin
            .top(view.pin.safeArea.top + 50)
            .horizontally(20)
            .sizeToFit(.width)
        
        let tailSpace = wheelPicker.configuration.tailSize.height
        wheelPicker.pin
            .center()
            .size(CGSize(width: 300, height: 80 + tailSpace))
    }
    
    private func setupWheelPicker() {
        let emojis = ["😀", "😎", "🤔", "👽", "🤖", "👾", "😈", "👻", "🤡", "🎉"]
        
        wheelPicker.delegate = self
        wheelPicker.configure(with: emojis, selectedIndex: 1)
        
        wheelPicker.configuration.itemWidth = 60
        wheelPicker.configuration.itemHeight = 60
        wheelPicker.configuration.font = .systemFont(ofSize: 40)
        wheelPicker.configuration.selectedTextColor = .label
        wheelPicker.configuration.deselectedTextColor = .secondaryLabel
        wheelPicker.configuration.selectionIndicatorColor = .systemBlue
        wheelPicker.configuration.tailPosition = .bottom
    }
}

extension ViewController: HorizontalWheelPickerDelegate {
    public func wheelPicker(_ picker: HorizontalWheelPicker, didSelectItemAt index: Int) {
        let emojis = ["😀", "😎", "🤔", "👽", "🤖", "👾", "😈", "👻", "🤡", "🎉"]
        resultLabel.text = "Selected: \(emojis[index])"
    }
}
