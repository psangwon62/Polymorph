import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        VStack {
            ColorPicker("Pick color", selection: $viewModel.selectedColor, supportsOpacity: true)
            Rectangle()
                .fill(viewModel.selectedColor)
                .onTapGesture {
                    print("Color")
                }
            Rectangle()
                .fill(viewModel.closestColor ?? Color.black)
                .onTapGesture {
                    print(viewModel.selectedColor)
                    print(viewModel.closestColor)
                }
                .onChange(of: viewModel.selectedColor) { _ in
                    Task {
                        await viewModel.closestColor()
                    }
                }
        }
    }
}
