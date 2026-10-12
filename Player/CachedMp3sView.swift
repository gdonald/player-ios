
import SwiftUI

struct CachedMp3sView: View {
    @EnvironmentObject var themeStore: ThemeStore
    @ObservedObject var mp3Cache: Mp3Cache
    @State private var searchText: String = UserDefaults.standard.string(forKey: "savedCachedMp3sSearchText") ?? ""
    let networkManager: NetworkManager

    var filteredItems: [CachedMp3] {
        if searchText.isEmpty {
            return mp3Cache.cachedMp3s.sorted { $0.id < $1.id }
        } else {
            return mp3Cache.cachedMp3s.filter {
                $0.nameForList(networkManager: networkManager)
                    .localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.id < $1.id }
        }
    }

    var body: some View {
        let theme = themeStore.theme

        WinampWindow(theme: theme, title: "Cache") {
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    LCDField(theme: theme, prompt: "Search", text: $searchText)

                    Button {
                        clearCache()
                    } label: {
                        Text("Clear (\(mp3Cache.cachedMp3s.count))")
                    }
                    .buttonStyle(BevelButtonStyle(theme: theme))
                }

                VStack(spacing: 0) {
                    ColumnHeaders(theme: theme, columns: [("Title", nil)])

                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredItems) { cachedMp3 in
                                CachedMp3ListItem(
                                    theme: theme,
                                    cachedMp3: cachedMp3,
                                    networkManager: networkManager
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    mp3Cache.removeMp3(cachedMp3: cachedMp3)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .lcdPanel(theme, background: theme.listBackground)
                .refreshable {
                    mp3Cache.refreshList()
                }
                .onAppear {
                    mp3Cache.refreshList()
                }
            }
        }
        .frame(maxHeight: .infinity)
        .onChange(of: searchText) { _, newValue in
            UserDefaults.standard.set(newValue, forKey: "savedCachedMp3sSearchText")
        }
    }

    private func clearCache() {
        let delayInterval = 0.01
        for (index, cachedMp3) in mp3Cache.cachedMp3s.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delayInterval * Double(index)) {
                mp3Cache.removeMp3(cachedMp3: cachedMp3)
                mp3Cache.refreshList()
            }
        }
    }
}
