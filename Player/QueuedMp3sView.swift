
import SwiftUI

struct QueuedMp3sView: View {
    @EnvironmentObject var themeStore: ThemeStore
    @ObservedObject var networkManager: NetworkManager
    @ObservedObject var audioPlayer: AudioPlayer
    @State private var searchText: String = UserDefaults.standard.string(forKey: "savedQueuedMp3sSearchText") ?? ""
    @State private var message: String?

    private var sortedQueue: [QueuedMp3] {
        networkManager.queuedMp3s.sorted { $0.position < $1.position }
    }

    private var numberedItems: [(number: Int, queuedMp3: QueuedMp3)] {
        let numbered = sortedQueue.enumerated().map { (number: $0.offset + 1, queuedMp3: $0.element) }

        if searchText.isEmpty {
            return numbered
        }

        return numbered.filter {
            $0.queuedMp3.mp3.title.localizedCaseInsensitiveContains(searchText)
                || $0.queuedMp3.mp3.artist_name.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var currentNumber: Int? {
        sortedQueue.firstIndex { $0 == networkManager.currentMp3 }.map { $0 + 1 }
    }

    private var totalLength: Int {
        networkManager.queuedMp3s.reduce(0) { $0 + $1.mp3.length }
    }

    private var marqueeText: String {
        guard let current = networkManager.currentMp3?.mp3 else { return "Nothing queued" }

        return "\(currentNumber ?? 0). \(current.artist_name) - \(current.title) (\(formatTime(current.length)))"
    }

    var body: some View {
        let theme = themeStore.theme
        let current = networkManager.currentMp3?.mp3

        VStack(spacing: 6) {
            WinampWindow(theme: theme, title: "Player") {
                ThemePicker(networkManager: networkManager)
            } content: {
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: audioPlayer.isPlaying ? "play.fill" : "pause.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(theme.display)

                            Text(formatTime(Int(audioPlayer.currentTime)))
                                .font(Theme.digits(28, relativeTo: .title))
                                .foregroundStyle(theme.display)
                        }
                        .padding(.horizontal, 8)
                        .frame(height: 48)
                        .lcdPanel(theme)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(marqueeText)
                                .font(Theme.text(11, relativeTo: .caption))
                                .foregroundStyle(theme.display)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)

                            HStack {
                                Text(current?.album_name ?? "")
                                    .font(Theme.text(10, relativeTo: .caption2))
                                    .foregroundStyle(theme.displayDim)
                                    .lineLimit(1)

                                Spacer()

                                Text(formatTime(current?.length ?? 0))
                                    .font(Theme.digits(11, relativeTo: .caption2))
                                    .foregroundStyle(theme.display)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
                        .lcdPanel(theme)
                    }

                    SeekBar(theme: theme, value: audioPlayer.currentTime, upperBound: Double(current?.length ?? 0)) { seconds in
                        audioPlayer.seek(to: seconds)
                    }

                    HStack(spacing: 4) {
                        Button {
                            if current != nil {
                                audioPlayer.playPause()
                            }
                        } label: {
                            Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                                .frame(width: 20)
                        }
                        .buttonStyle(BevelButtonStyle(theme: theme))
                        .accessibilityLabel(audioPlayer.isPlaying ? "Pause" : "Play")

                        Button {
                            networkManager.nextQueuedMp3()
                        } label: {
                            Image(systemName: "forward.end.fill")
                                .frame(width: 20)
                        }
                        .buttonStyle(BevelButtonStyle(theme: theme))
                        .accessibilityLabel("Next")

                        Spacer()
                    }
                }
            }

            WinampWindow(theme: theme, title: "Playlist") {
                VStack(spacing: 4) {
                    LCDField(theme: theme, prompt: "Search", text: $searchText)

                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(numberedItems, id: \.queuedMp3.id) { item in
                                QueuedMp3ListItem(
                                    theme: theme,
                                    number: item.number,
                                    queuedMp3: item.queuedMp3,
                                    isCurrent: item.number == currentNumber
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    remove(item.queuedMp3)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .lcdPanel(theme, background: theme.listBackground)
                    .refreshable {
                        networkManager.fetchQueuedMp3s()
                    }

                    HStack {
                        Spacer()

                        Text(formatTime(totalLength))
                            .font(Theme.digits(11, relativeTo: .caption2))
                            .foregroundStyle(theme.display)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .lcdPanel(theme)
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
        .onChange(of: searchText) { _, newValue in
            UserDefaults.standard.set(newValue, forKey: "savedQueuedMp3sSearchText")
        }
        .overlay(Toast(theme: theme, message: message))
        .animation(.easeInOut, value: message)
    }

    private func remove(_ queuedMp3: QueuedMp3) {
        flash("\"\(queuedMp3.mp3.title)\"\nremoved from queue")
        networkManager.deleteQueuedMp3(queuedMp3Id: String(queuedMp3.id))
    }

    private func flash(_ text: String) {
        message = text
        Task {
            try? await Task.sleep(for: .seconds(2))
            message = nil
        }
    }
}
