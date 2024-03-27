
import SwiftUI
import ComposableArchitecture

@main
struct HeadwayNibblePlayerTestApp: App {
    var body: some Scene {
        WindowGroup {
            AudioPlayerView(
                store: Store(initialState: AudioPlayerFeature.State(book: BookModel.mockBook)) {
                    AudioPlayerFeature()
                }
            )
        }
    }
}
