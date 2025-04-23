import SwiftUI

struct ContentView: View {
    @ObservedObject var vm: ContentViewModel
    
    init(vm: ContentViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}
