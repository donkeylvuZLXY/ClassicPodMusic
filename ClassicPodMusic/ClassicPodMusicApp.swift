import SwiftUI

@main
struct ClassicPodMusicApp: App {
    @StateObject private var library = MusicLibraryModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(library)
        }
    }
}
