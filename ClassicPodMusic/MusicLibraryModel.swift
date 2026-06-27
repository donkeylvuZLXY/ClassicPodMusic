import Foundation
import MusicKit

@MainActor
final class MusicLibraryModel: ObservableObject {
    enum LoadState: Equatable {
        case idle
        case requestingAccess
        case loading
        case ready
        case unavailable(String)
    }

    @Published private(set) var authorizationStatus: MusicAuthorization.Status = MusicAuthorization.currentStatus
    @Published private(set) var loadState: LoadState = .idle
    @Published private(set) var songs: [Song] = []
    @Published private(set) var selectedSongID: MusicItemID?
    @Published private(set) var nowPlaying: Song?
    @Published private(set) var isPlaying = false

    private let player = ApplicationMusicPlayer.shared

    var selectedSong: Song? {
        guard let selectedSongID else {
            return songs.first
        }

        return songs.first { $0.id == selectedSongID }
    }

    func bootstrap() async {
        authorizationStatus = MusicAuthorization.currentStatus

        if authorizationStatus == .authorized, songs.isEmpty {
            await loadLibrary()
        }
    }

    func requestAccess() async {
        loadState = .requestingAccess
        authorizationStatus = await MusicAuthorization.request()

        guard authorizationStatus == .authorized else {
            loadState = .unavailable("Apple Music access was not allowed.")
            return
        }

        await loadLibrary()
    }

    func reload() async {
        guard authorizationStatus == .authorized else {
            await requestAccess()
            return
        }

        await loadLibrary()
    }

    func select(index: Int) {
        guard songs.indices.contains(index) else {
            return
        }

        selectedSongID = songs[index].id
    }

    func selectPrevious() {
        moveSelection(by: -1)
    }

    func selectNext() {
        moveSelection(by: 1)
    }

    func playSelected() async {
        guard let song = selectedSong else {
            return
        }

        do {
            player.queue = [song]
            try await player.play()
            nowPlaying = song
            isPlaying = true
        } catch {
            loadState = .unavailable("Playback failed: \(error.localizedDescription)")
        }
    }

    func togglePlayPause() async {
        guard nowPlaying != nil else {
            await playSelected()
            return
        }

        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            do {
                try await player.play()
                isPlaying = true
            } catch {
                loadState = .unavailable("Playback failed: \(error.localizedDescription)")
            }
        }
    }

    func playPrevious() async {
        selectPrevious()
        await playSelected()
    }

    func playNext() async {
        selectNext()
        await playSelected()
    }

    private func loadLibrary() async {
        loadState = .loading

        do {
            var request = MusicLibraryRequest<Song>()
            request.limit = 200
            let response = try await request.response()
            let sortedSongs = response.items.sorted {
                let lhs = $0.title.localizedCaseInsensitiveCompare($1.title)
                if lhs == .orderedSame {
                    return $0.artistName.localizedCaseInsensitiveCompare($1.artistName) == .orderedAscending
                }

                return lhs == .orderedAscending
            }

            songs = sortedSongs
            selectedSongID = selectedSongID ?? sortedSongs.first?.id
            loadState = sortedSongs.isEmpty ? .unavailable("No songs were found in your Apple Music library.") : .ready
        } catch {
            loadState = .unavailable("Library load failed: \(error.localizedDescription)")
        }
    }

    private func moveSelection(by offset: Int) {
        guard !songs.isEmpty else {
            return
        }

        let currentIndex: Int
        if let selectedSongID, let index = songs.firstIndex(where: { $0.id == selectedSongID }) {
            currentIndex = index
        } else {
            currentIndex = 0
        }

        let nextIndex = (currentIndex + offset + songs.count) % songs.count
        selectedSongID = songs[nextIndex].id
    }
}
