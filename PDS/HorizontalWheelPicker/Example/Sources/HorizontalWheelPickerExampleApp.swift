import SwiftUI
import HorizontalWheelPicker

@main
struct HorizontalWheelPickerExampleApp: App {
    var body: some Scene {
        WindowGroup {
            VStack {
                VCWrapper()
            }
        }
    }
}

struct VCWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewController {
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
    }
}
