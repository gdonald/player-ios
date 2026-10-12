
import SwiftUI

struct Mp3sView: View {
    @EnvironmentObject var themeStore: ThemeStore
    @ObservedObject var networkManager: NetworkManager
    @State private var searchText: String = UserDefaults.standard.string(forKey: "savedMp3sSearchText") ?? ""
    @State private var message: String?

    var filteredItems: [Mp3] {
        if searchText.isEmpty {
            return networkManager.mp3s
        } else {
            return networkManager.mp3s.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
                    ||
                    $0.artist_name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        let theme = themeStore.theme

        WinampWindow(theme: theme, title: "Mp3s") {
            VStack(spacing: 4) {
                LCDField(theme: theme, prompt: "Search", text: $searchText)

                VStack(spacing: 0) {
                    ColumnHeaders(theme: theme, columns: [("Title", nil), ("Artist", 130)])

                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredItems) { mp3 in
                                Mp3ListItem(theme: theme, mp3: mp3)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        enqueue(mp3)
                                    }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .lcdPanel(theme, background: theme.listBackground)
            }
        }
        .frame(maxHeight: .infinity)
        .onChange(of: searchText) { _, newValue in
            UserDefaults.standard.set(newValue, forKey: "savedMp3sSearchText")
        }
        .overlay(Toast(theme: theme, message: message))
        .animation(.easeInOut, value: message)
    }

    private func enqueue(_ mp3: Mp3) {
        flash("\"\(mp3.title)\"\nadded to queue")
        networkManager.createQueuedMp3(mp3Id: String(mp3.id))
    }

    private func flash(_ text: String) {
        message = text
        Task {
            try? await Task.sleep(for: .seconds(2))
            message = nil
        }
    }
}
