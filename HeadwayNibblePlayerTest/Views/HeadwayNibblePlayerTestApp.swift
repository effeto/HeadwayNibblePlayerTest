//
//  HeadwayNibblePlayerTestApp.swift
//  HeadwayNibblePlayerTest
//
//  Created by Демьян on 27.03.2024.
//

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
