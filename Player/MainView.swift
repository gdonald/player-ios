
import SwiftUI

enum MainTab: CaseIterable {
    case queue
    case playlists
    case mp3s
    case cache

    var label: String {
        switch self {
        case .queue: "Queue"
        case .playlists: "Playlists"
        case .mp3s: "Mp3s"
        case .cache: "Cache"
        }
    }

    var icon: String {
        switch self {
        case .queue: "text.insert"
        case .playlists: "music.note.list"
        case .mp3s: "music.note"
        case .cache: "square.and.arrow.down.on.square"
        }
    }
}

struct MainView: View {
    @EnvironmentObject var userAuth: UserAuth
    @StateObject private var networkManager = NetworkManager()
    @StateObject private var mp3Cache = Mp3Cache()
    @StateObject private var audioPlayer = AudioPlayer()
    @StateObject private var themeStore = ThemeStore()
    @State private var selectedTab: MainTab = .queue

    private var counts: [MainTab: Int] {
        [
            .queue: networkManager.queuedMp3s.count,
            .playlists: networkManager.playlists.count,
            .mp3s: networkManager.mp3s.count,
            .cache: mp3Cache.cachedMp3s.count,
        ]
    }

    var body: some View {
        let theme = themeStore.theme

        Group {
            if userAuth.isAuthenticated {
                VStack(spacing: 6) {
                    selectedView

                    LibraryBar(theme: theme, selectedTab: $selectedTab, counts: counts)
                }
                .padding([.top, .horizontal], 6)
                .ignoresSafeArea(edges: .bottom)
                .task {
                    networkManager.fetch()
                    await themeStore.load(using: networkManager)
                }
                .onChange(of: networkManager.currentMp3) {
                    if let mp3 = networkManager.currentMp3?.mp3 {
                        audioPlayer.newMp3(mp3: mp3)
                    }
                }
                .onChange(of: audioPlayer.ended) {
                    if audioPlayer.ended {
                        networkManager.nextQueuedMp3()
                    }
                }
            } else {
                LoginView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.desktop.ignoresSafeArea())
        .environmentObject(themeStore)
        .preferredColorScheme(.dark)
    }

    @ViewBuilder private var selectedView: some View {
        switch selectedTab {
        case .queue:
            QueuedMp3sView(networkManager: networkManager, audioPlayer: audioPlayer)
        case .playlists:
            PlaylistsView(networkManager: networkManager)
        case .mp3s:
            Mp3sView(networkManager: networkManager)
        case .cache:
            CachedMp3sView(mp3Cache: mp3Cache, networkManager: networkManager)
        }
    }
}

struct LibraryBar: View {
    let theme: Theme
    @Binding var selectedTab: MainTab
    let counts: [MainTab: Int]

    var body: some View {
        WinampWindow(theme: theme, title: "Library") {
            HStack(spacing: 4) {
                ForEach(MainTab.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        VStack(spacing: 3) {
                            HStack(spacing: 4) {
                                WinampLight(theme: theme, on: selectedTab == tab)
                                Image(systemName: tab.icon)
                                    .font(.system(size: 12))
                            }
                            .frame(height: 14)

                            Text(tab.label)
                                .font(Theme.text(9, weight: .bold, relativeTo: .caption2))
                                .lineLimit(1)

                            Text(counts[tab]?.formatted() ?? " ")
                                .font(Theme.digits(10, relativeTo: .caption2))
                                .foregroundStyle(theme.display)
                                .padding(.horizontal, 4)
                                .background(counts[tab] == nil ? .clear : theme.lcd)
                        }
                        .frame(maxWidth: .infinity, minHeight: 46)
                    }
                    .buttonStyle(BevelButtonStyle(theme: theme, lit: selectedTab == tab, horizontalPadding: 2))
                    .accessibilityLabel(tab.label)
                }
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(UserAuth())
}
