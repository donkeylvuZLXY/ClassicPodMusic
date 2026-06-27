import Foundation
import MusicKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var library: MusicLibraryModel
    @State private var screenMode: ScreenMode = .nowPlaying

    var body: some View {
        GeometryReader { proxy in
            FullScreenPodDevice(
                screenMode: $screenMode,
                size: proxy.size,
                safeArea: proxy.safeAreaInsets
            )
        }
        .ignoresSafeArea()
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .task {
            await library.bootstrap()
        }
    }
}

private enum ScreenMode {
    case library
    case nowPlaying
}

private struct FullScreenPodDevice: View {
    @Binding var screenMode: ScreenMode
    let size: CGSize
    let safeArea: EdgeInsets

    private var horizontalPadding: CGFloat {
        min(max(size.width * 0.030, 10), 16)
    }

    private var topPadding: CGFloat {
        min(max(size.height * 0.018, 12), 20)
    }

    private var bottomPadding: CGFloat {
        min(max(size.height * 0.012, 8), 16)
    }

    private var screenHeight: CGFloat {
        min(size.height * 0.405, size.width * 0.96)
    }

    private var wheelDiameter: CGFloat {
        min(size.width * 0.94, size.height * 0.405)
    }

    var body: some View {
        ZStack {
            LiquidBackdrop()

            Rectangle()
                .fill(Color.white.opacity(0.05))
                .liquidGlass(tint: Color.white.opacity(0.12), in: Rectangle())

            shellHighlights

            VStack(spacing: 0) {
                PlayerScreen(screenMode: $screenMode)
                    .frame(maxWidth: .infinity)
                    .frame(height: screenHeight)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, topPadding)

                Spacer(minLength: 10)

                ClickWheel(screenMode: $screenMode, diameter: wheelDiameter)

                Spacer(minLength: bottomPadding + safeArea.bottom * 0.20)
            }
            .frame(width: size.width, height: size.height)
        }
        .accessibilityElement(children: .contain)
    }

    private var shellHighlights: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.white.opacity(0.42),
                    Color.white.opacity(0.05),
                    Color.black.opacity(0.16)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blendMode(.screen)

            LinearGradient(
                colors: [
                    Color.clear,
                    Color.white.opacity(0.20),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: size.width * 0.42)
            .rotationEffect(.degrees(-18))
            .offset(x: -size.width * 0.18, y: -size.height * 0.07)
            .blendMode(.screen)

            VStack {
                Rectangle()
                    .fill(Color.white.opacity(0.30))
                    .frame(height: 1)
                    .padding(.top, safeArea.top + 5)

                Spacer()

                Rectangle()
                    .fill(Color.black.opacity(0.14))
                    .frame(height: 1)
                    .padding(.bottom, safeArea.bottom + 4)
            }
        }
        .allowsHitTesting(false)
    }
}

private struct LiquidBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.07, blue: 0.09),
                    Color(red: 0.28, green: 0.35, blue: 0.42),
                    Color(red: 0.82, green: 0.85, blue: 0.84)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            DiagonalGlassColorBand(
                color: Color(red: 0.14, green: 0.40, blue: 0.58),
                width: 160,
                angle: -22,
                x: -130,
                y: -180
            )

            DiagonalGlassColorBand(
                color: Color(red: 0.95, green: 0.68, blue: 0.28),
                width: 130,
                angle: 18,
                x: 86,
                y: -40
            )

            DiagonalGlassColorBand(
                color: Color(red: 0.75, green: 0.25, blue: 0.66),
                width: 150,
                angle: -26,
                x: 148,
                y: 230
            )
        }
        .saturation(1.12)
        .ignoresSafeArea()
    }
}

private struct DiagonalGlassColorBand: View {
    let color: Color
    let width: CGFloat
    let angle: Double
    let x: CGFloat
    let y: CGFloat

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        color.opacity(0.0),
                        color.opacity(0.72),
                        color.opacity(0.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width, height: 1200)
            .rotationEffect(.degrees(angle))
            .offset(x: x, y: y)
            .blur(radius: 3)
            .blendMode(.screen)
            .allowsHitTesting(false)
    }
}

private struct PlayerScreen: View {
    @EnvironmentObject private var library: MusicLibraryModel
    @Binding var screenMode: ScreenMode

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.screenGlass.opacity(0.62))
                .overlay(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.26),
                                    Color.white.opacity(0.06),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

            screenContent
                .padding(.horizontal, 18)
                .padding(.vertical, 16)

            if let playbackErrorMessage = library.playbackErrorMessage {
                VStack {
                    Spacer()

                    Text(playbackErrorMessage)
                        .font(.screenSmall)
                        .foregroundStyle(Color.screenGlass)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background {
                            Capsule()
                                .fill(Color.screenHighlight.opacity(0.92))
                        }
                        .padding(.horizontal, 14)
                        .padding(.bottom, 12)
                }
                .transition(.opacity)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                .blendMode(.screen)
        }
        .liquidGlass(tint: Color.screenGlass.opacity(0.34), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
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
        VStack(spacing: 12) {
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
                    LazyVStack(spacing: 5) {
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
                    .padding(.bottom, 4)
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
            HStack(spacing: 9) {
                Text("\(index + 1)")
                    .font(.screenSmall)
                    .monospacedDigit()
                    .foregroundStyle(isSelected ? Color.screenGlass : Color.screenMuted)
                    .frame(width: 30, alignment: .trailing)

                VStack(alignment: .leading, spacing: 2) {
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
            .padding(.horizontal, 9)
            .padding(.vertical, 8)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        isSelected
                        ? Color.screenHighlight.opacity(0.90)
                        : Color.white.opacity(0.001)
                    )
            }
        }
        .buttonStyle(.plain)
    }
}

private struct NowPlayingPanel: View {
    @EnvironmentObject private var library: MusicLibraryModel
    @State private var carouselIndex = 0
    @State private var didSyncInitialSelection = false
    @State private var isSyncingFromModel = false

    var body: some View {
        ScreenChrome(title: "Now Playing") {
            if library.songs.isEmpty {
                ScreenStatus(title: "Music", message: "No selection")
            } else {
                GeometryReader { proxy in
                    TabView(selection: $carouselIndex) {
                        ForEach(Array(library.songs.enumerated()), id: \.element.id) { index, song in
                            AlbumCoverPage(
                                song: song,
                                isPlaying: library.isPlaying && song.id == library.nowPlaying?.id,
                                size: proxy.size
                            )
                            .tag(index)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                library.select(index: index)
                                Task {
                                    await library.playSelected()
                                }
                            }
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .onAppear {
                        syncCarouselToSelection()
                        DispatchQueue.main.async {
                            didSyncInitialSelection = true
                        }
                    }
                    .onChange(of: library.selectedSongID) { _ in
                        syncCarouselToSelection()
                    }
                    .onChange(of: carouselIndex) { index in
                        guard didSyncInitialSelection, !isSyncingFromModel else {
                            return
                        }

                        guard library.songs.indices.contains(index) else {
                            return
                        }

                        library.select(index: index)
                        Task {
                            await library.playSelected()
                        }
                    }
                }
            }
        }
    }

    private func syncCarouselToSelection() {
        let targetIndex = selectedSongIndex
        guard targetIndex != carouselIndex else {
            return
        }

        isSyncingFromModel = true
        carouselIndex = targetIndex
        DispatchQueue.main.async {
            isSyncingFromModel = false
        }
    }

    private var selectedSongIndex: Int {
        guard let selectedSongID = library.selectedSongID else {
            return 0
        }

        return library.songs.firstIndex { $0.id == selectedSongID } ?? 0
    }
}

private struct AlbumCoverPage: View {
    let song: Song
    let isPlaying: Bool
    let size: CGSize

    private var artworkSize: CGFloat {
        min(size.width * 0.64, size.height * 0.62, 190)
    }

    var body: some View {
        VStack(spacing: 9) {
            ArtworkTile(song: song, size: artworkSize)
                .shadow(color: Color.black.opacity(0.28), radius: 14, x: 0, y: 8)

            VStack(spacing: 3) {
                Text(song.title)
                    .font(.screenTitle)
                    .foregroundStyle(Color.screenTint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(song.artistName)
                    .font(.screenBody)
                    .foregroundStyle(Color.screenMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
            .frame(maxWidth: size.width * 0.86)

            HStack(spacing: 8) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 11, weight: .bold))

                Text(DurationText.string(from: song.duration))
                    .font(.screenSmall)
                    .monospacedDigit()
            }
            .foregroundStyle(Color.screenTint)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.horizontal, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(song.title), \(song.artistName)")
    }
}

private struct ArtworkTile: View {
    let song: Song
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.screenMuted.opacity(0.18))

            if let artwork = song.artwork {
                ArtworkImage(artwork, width: size, height: size)
                    .aspectRatio(contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                Image(systemName: "music.note")
                    .font(.system(size: size * 0.36, weight: .semibold))
                    .foregroundStyle(Color.screenMuted)
            }
        }
        .frame(width: size, height: size)
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.screenTint.opacity(0.25), lineWidth: 1)
        }
    }
}

private struct LoadingPanel: View {
    var body: some View {
        ScreenStatus(title: "Music", message: "Loading")
            .overlay(alignment: .bottom) {
                ProgressView()
                    .tint(Color.screenTint)
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
        VStack(spacing: 14) {
            ScreenStatus(title: title, message: message)

            Button(action: action) {
                Text(buttonTitle)
                    .font(.screenBody)
                    .foregroundStyle(Color.screenGlass)
                    .lineLimit(1)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background {
                        Capsule()
                            .fill(Color.screenHighlight)
                    }
                    .liquidGlass(interactive: true, tint: Color.screenHighlight.opacity(0.30), in: Capsule())
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
        VStack(spacing: 8) {
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
    let diameter: CGFloat

    private var controlButtonSize: CGFloat {
        diameter * 0.23
    }

    private var centerButtonSize: CGFloat {
        diameter * 0.38
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.18))
                .overlay {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.70),
                                    Color.white.opacity(0.18),
                                    Color.black.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.screen)
                }
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.55), lineWidth: 1)
                }
                .liquidGlass(interactive: true, tint: Color.white.opacity(0.20), in: Circle())

            VStack {
                WheelTextButton(title: "MENU", width: diameter * 0.31, height: diameter * 0.17) {
                    screenMode = .library
                }

                Spacer()

                WheelIconButton(
                    systemName: library.isPlaying ? "pause.fill" : "play.fill",
                    label: "Play or pause",
                    size: controlButtonSize
                ) {
                    Task {
                        await library.togglePlayPause()
                    }
                    screenMode = .nowPlaying
                }
            }
            .padding(.vertical, diameter * 0.045)

            HStack {
                WheelIconButton(systemName: "backward.fill", label: "Previous", size: controlButtonSize) {
                    Task {
                        await library.playPrevious()
                    }
                    screenMode = .nowPlaying
                }

                Spacer()

                WheelIconButton(systemName: "forward.fill", label: "Next", size: controlButtonSize) {
                    Task {
                        await library.playNext()
                    }
                    screenMode = .nowPlaying
                }
            }
            .padding(.horizontal, diameter * 0.045)

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
                    .fill(Color.white.opacity(0.16))
                    .overlay {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.35),
                                        Color.black.opacity(0.09)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay {
                        Circle()
                            .stroke(Color.white.opacity(0.34), lineWidth: 1)
                    }
                    .overlay {
                        Image(systemName: "circle.fill")
                            .font(.system(size: diameter * 0.072, weight: .regular))
                            .foregroundStyle(Color.controlInk.opacity(0.58))
                    }
                    .frame(width: centerButtonSize, height: centerButtonSize)
                    .liquidGlass(interactive: true, tint: Color.white.opacity(0.15), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Select")
        }
        .frame(width: diameter, height: diameter)
    }
}

private struct WheelIconButton: View {
    let systemName: String
    let label: String
    let size: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size * 0.34, weight: .semibold))
                .foregroundStyle(Color.controlInk)
                .frame(width: size, height: size)
                .contentShape(Circle())
                .liquidGlass(interactive: true, tint: Color.white.opacity(0.10), in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

private struct WheelTextButton: View {
    let title: String
    let width: CGFloat
    let height: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: max(13, height * 0.30), weight: .bold, design: .rounded))
                .foregroundStyle(Color.controlInk)
                .frame(width: width, height: height)
                .contentShape(Capsule())
                .liquidGlass(interactive: true, tint: Color.white.opacity(0.08), in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

private extension View {
    @ViewBuilder
    func liquidGlass<S: Shape>(interactive: Bool = false, tint: Color? = nil, in shape: S) -> some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            if interactive {
                self.glassEffect(.regular.interactive(), in: shape)
            } else {
                self.glassEffect(.regular, in: shape)
            }
        } else {
            self.legacyLiquidGlass(interactive: interactive, tint: tint, in: shape)
        }
        #else
        self.legacyLiquidGlass(interactive: interactive, tint: tint, in: shape)
        #endif
    }

    private func legacyLiquidGlass<S: Shape>(interactive: Bool, tint: Color?, in shape: S) -> some View {
        self
            .background(.ultraThinMaterial, in: shape)
            .overlay {
                ZStack {
                    if let tint {
                        shape
                            .fill(tint.opacity(interactive ? 0.20 : 0.14))
                            .blendMode(.overlay)
                    }

                    shape
                        .stroke(Color.white.opacity(interactive ? 0.42 : 0.26), lineWidth: 1)
                        .blendMode(.screen)
                }
            }
            .shadow(
                color: Color.black.opacity(interactive ? 0.14 : 0.20),
                radius: interactive ? 8 : 16,
                x: 0,
                y: interactive ? 5 : 10
            )
    }
}
