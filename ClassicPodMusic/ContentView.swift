import MusicKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var library: MusicLibraryModel
    @State private var screenMode: ScreenMode = .library

    var body: some View {
        ZStack {
            LiquidBackdrop()

            GeometryReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        ClassicPlayerDevice(screenMode: $screenMode)
                            .padding(.horizontal, proxy.size.width <= 430 ? 13 : 18)
                            .padding(.top, proxy.size.width <= 430 && proxy.size.height >= 820 ? 26 : 28)
                            .padding(.bottom, 28)
                    }
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height, alignment: .top)
                }
            }
        }
        .task {
            await library.bootstrap()
        }
    }
}

private struct LiquidBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.08, blue: 0.10),
                    Color(red: 0.34, green: 0.40, blue: 0.45),
                    Color(red: 0.85, green: 0.87, blue: 0.86)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.12, green: 0.33, blue: 0.48).opacity(0.90), location: 0.00),
                    .init(color: .clear, location: 0.22),
                    .init(color: Color(red: 0.92, green: 0.62, blue: 0.28).opacity(0.72), location: 0.42),
                    .init(color: .clear, location: 0.62),
                    .init(color: Color(red: 0.56, green: 0.24, blue: 0.54).opacity(0.68), location: 0.82)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blur(radius: 18)
        }
        .ignoresSafeArea()
    }
}

private enum ScreenMode {
    case library
    case nowPlaying
}

private struct ClassicPlayerDevice: View {
    @EnvironmentObject private var library: MusicLibraryModel
    @Binding var screenMode: ScreenMode

    var body: some View {
        VStack(spacing: 24) {
            PlayerScreen(screenMode: $screenMode)
            ClickWheel(screenMode: $screenMode)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 30)
        .frame(maxWidth: 420)
        .background {
            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .fill(Color.white.opacity(0.18))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 42, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 42, style: .continuous)
                        .stroke(Color.white.opacity(0.52), lineWidth: 1)
                }
                .shadow(color: .shellShadow.opacity(0.34), radius: 28, x: 0, y: 22)
        }
        .liquidGlass(in: RoundedRectangle(cornerRadius: 42, style: .continuous))
        .accessibilityElement(children: .contain)
    }
}

private struct PlayerScreen: View {
    @EnvironmentObject private var library: MusicLibraryModel
    @Binding var screenMode: ScreenMode

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.screenGlass)
                .overlay(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.13), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )
                }

            screenContent
                .padding(14)
        }
        .aspectRatio(1.36, contentMode: .fit)
        .frame(maxWidth: 360)
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
        }
        .liquidGlass(in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    @ViewBuilder
    private var screenContent: some View {
        switch library.authorizationStatus {
        case .notDetermined:
            AccessPanel(
                title: "Apple Music",
                message: "Connect your library",
                buttonTitle: "Connect"
            ) {
                Task {
                    await library.requestAccess()
                }
            }
        case .denied, .restricted:
            AccessPanel(
                title: "Access Blocked",
                message: "Enable Apple Music access in Settings",
                buttonTitle: "Retry"
            ) {
                Task {
                    await library.requestAccess()
                }
            }
        case .authorized:
            authorizedContent
        @unknown default:
            AccessPanel(
                title: "Apple Music",
                message: "Unsupported authorization state",
                buttonTitle: "Reload"
            ) {
                Task {
                    await library.reload()
                }
            }
        }
    }

    @ViewBuilder
    private var authorizedContent: some View {
        switch library.loadState {
        case .idle:
            ScreenStatus(title: "Music", message: "Ready")
        case .requestingAccess, .loading:
            LoadingPanel()
        case .unavailable(let message):
            AccessPanel(title: "Library", message: message, buttonTitle: "Reload") {
                Task {
                    await library.reload()
                }
            }
        case .ready:
            switch screenMode {
            case .library:
                LibraryPanel(screenMode: $screenMode)
            case .nowPlaying:
                NowPlayingPanel()
            }
        }
    }
}

private struct ScreenChrome<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Text(title.uppercased())
                    .font(.screenSmall)
                    .foregroundStyle(Color.screenTint)
                    .lineLimit(1)

                Spacer(minLength: 8)

                Image(systemName: "battery.100")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.screenMuted)
            }

            content
        }
    }
}

private struct LibraryPanel: View {
    @EnvironmentObject private var library: MusicLibraryModel
    @Binding var screenMode: ScreenMode

    var body: some View {
        ScreenChrome(title: "Library") {
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 3) {
                        ForEach(Array(library.songs.enumerated()), id: \.element.id) { index, song in
                            SongRow(
                                index: index,
                                song: song,
                                isSelected: song.id == library.selectedSongID,
                                isCurrent: song.id == library.nowPlaying?.id,
                                isPlaying: library.isPlaying
                            ) {
                                library.select(index: index)
                                screenMode = .nowPlaying
                                Task {
                                    await library.playSelected()
                                }
                            }
                            .id(song.id)
                        }
                    }
                }
                .onChange(of: library.selectedSongID) { selectedID in
                    guard let selectedID else {
                        return
                    }

                    withAnimation(.easeInOut(duration: 0.18)) {
                        proxy.scrollTo(selectedID, anchor: .center)
                    }
                }
            }
        }
    }
}

private struct SongRow: View {
    let index: Int
    let song: Song
    let isSelected: Bool
    let isCurrent: Bool
    let isPlaying: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text("\(index + 1)")
                    .font(.screenSmall)
                    .monospacedDigit()
                    .foregroundStyle(isSelected ? Color.screenGlass : Color.screenMuted)
                    .frame(width: 28, alignment: .trailing)

                VStack(alignment: .leading, spacing: 1) {
                    Text(song.title)
                        .font(.screenBody)
                        .foregroundStyle(isSelected ? Color.screenGlass : Color.screenTint)
                        .lineLimit(1)

                    Text(song.artistName)
                        .font(.screenSmall)
                        .foregroundStyle(isSelected ? Color.screenGlass.opacity(0.72) : Color.screenMuted)
                        .lineLimit(1)
                }

                Spacer(minLength: 6)

                if isCurrent {
                    Image(systemName: isPlaying ? "speaker.wave.2.fill" : "pause.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(isSelected ? Color.screenGlass : Color.screenTint)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(isSelected ? Color.screenHighlight : Color.clear)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct NowPlayingPanel: View {
    @EnvironmentObject private var library: MusicLibraryModel

    var body: some View {
        ScreenChrome(title: "Now Playing") {
            if let song = library.nowPlaying ?? library.selectedSong {
                HStack(spacing: 12) {
                    ArtworkTile(song: song)

                    VStack(alignment: .leading, spacing: 7) {
                        Text(song.title)
                            .font(.screenTitle)
                            .foregroundStyle(Color.screenTint)
                            .lineLimit(2)

                        Text(song.artistName)
                            .font(.screenBody)
                            .foregroundStyle(Color.screenMuted)
                            .lineLimit(1)

                        Spacer(minLength: 0)

                        HStack(spacing: 7) {
                            Image(systemName: library.isPlaying ? "play.fill" : "pause.fill")
                                .font(.system(size: 10, weight: .bold))

                            Text(DurationText.string(from: song.duration))
                                .font(.screenSmall)
                                .monospacedDigit()
                        }
                        .foregroundStyle(Color.screenTint)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                ScreenStatus(title: "Music", message: "No selection")
            }
        }
    }
}

private struct ArtworkTile: View {
    let song: Song

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.screenMuted.opacity(0.18))

            if let artwork = song.artwork {
                ArtworkImage(artwork, width: 116, height: 116)
                    .aspectRatio(contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                Image(systemName: "music.note")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(Color.screenMuted)
            }
        }
        .frame(width: 116, height: 116)
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.screenTint.opacity(0.25), lineWidth: 1)
        }
    }
}

private struct LoadingPanel: View {
    var body: some View {
        ScreenStatus(title: "Music", message: "Loading")
            .overlay(alignment: .bottom) {
                ProgressView()
                    .tint(.screenTint)
                    .padding(.bottom, 4)
            }
    }
}

private struct AccessPanel: View {
    let title: String
    let message: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            ScreenStatus(title: title, message: message)

            Button(action: action) {
                Text(buttonTitle)
                    .font(.screenBody)
                    .foregroundStyle(Color.screenGlass)
                    .lineLimit(1)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background {
                        Capsule()
                            .fill(Color.screenHighlight)
                    }
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ScreenStatus: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 7) {
            Text(title)
                .font(.screenTitle)
                .foregroundStyle(Color.screenTint)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(message)
                .font(.screenBody)
                .foregroundStyle(Color.screenMuted)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ClickWheel: View {
    @EnvironmentObject private var library: MusicLibraryModel
    @Binding var screenMode: ScreenMode

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.white, .wheelSurface, .wheelInner],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.70), lineWidth: 1)
                }
                .shadow(color: Color.black.opacity(0.24), radius: 12, x: 0, y: 8)

            VStack {
                WheelTextButton(title: "MENU") {
                    screenMode = .library
                }

                Spacer()

                WheelIconButton(systemName: library.isPlaying ? "pause.fill" : "play.fill", label: "Play or pause") {
                    Task {
                        await library.togglePlayPause()
                    }
                    screenMode = .nowPlaying
                }
            }
            .padding(.vertical, 17)

            HStack {
                WheelIconButton(systemName: "backward.fill", label: "Previous") {
                    Task {
                        await library.playPrevious()
                    }
                    screenMode = .nowPlaying
                }

                Spacer()

                WheelIconButton(systemName: "forward.fill", label: "Next") {
                    Task {
                        await library.playNext()
                    }
                    screenMode = .nowPlaying
                }
            }
            .padding(.horizontal, 17)

            Button {
                switch screenMode {
                case .library:
                    screenMode = .nowPlaying
                    Task {
                        await library.playSelected()
                    }
                case .nowPlaying:
                    Task {
                        await library.togglePlayPause()
                    }
                }
            } label: {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.wheelInner, .shellBottom],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        Circle()
                            .stroke(Color.black.opacity(0.12), lineWidth: 1)
                    }
                    .overlay {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundStyle(Color.controlInk.opacity(0.58))
                    }
                    .frame(width: 100, height: 100)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Select")
        }
        .frame(width: 258, height: 258)
        .liquidGlass(interactive: true, in: Circle())
    }
}

private struct WheelIconButton: View {
    let systemName: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(Color.controlInk)
                .frame(width: 58, height: 58)
                .contentShape(Circle())
                .liquidGlass(interactive: true, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

private struct WheelTextButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color.controlInk)
                .frame(width: 72, height: 42)
                .contentShape(Rectangle())
                .liquidGlass(interactive: true, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

private extension View {
    @ViewBuilder
    func liquidGlass<S: Shape>(interactive: Bool = false, in shape: S) -> some View {
        self
            .background(.ultraThinMaterial, in: shape)
            .overlay {
                shape
                    .stroke(Color.white.opacity(interactive ? 0.42 : 0.26), lineWidth: 1)
                    .blendMode(.screen)
            }
            .shadow(color: Color.black.opacity(interactive ? 0.14 : 0.20), radius: interactive ? 8 : 16, x: 0, y: interactive ? 5 : 10)
    }
}
