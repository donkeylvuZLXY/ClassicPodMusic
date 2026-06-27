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
