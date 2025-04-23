import EmojiMapper
import Logger
import SwiftUI

@main
struct EmojiMapperExampleApp: App {
    let contentViewModel = ContentViewModel(mapper: EmojiMapperImpl(LoggerService()))
    
    var body: some Scene {
        WindowGroup {
            ContentView(vm: contentViewModel)
        }
    }
}
