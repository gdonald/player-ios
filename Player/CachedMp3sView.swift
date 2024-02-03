
import SwiftUI

struct CachedMp3sView: View {
    @ObservedObject var mp3Cacher: Mp3Cacher
    @State private var searchText: String = UserDefaults.standard.string(forKey: "savedCachedMp3sSearchText") ?? ""

    var filteredItems: [CachedMp3] {
        if searchText.isEmpty {
            return mp3Cacher.cachedMp3s.sorted { $0.id < $1.id }
        } else {
            return mp3Cacher.cachedMp3s.filter {
                $0.nameForList().localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.id < $1.id }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    List(filteredItems) { cachedMp3 in
                        CachedMp3ListItem(
                            cachedMp3: cachedMp3
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .listRowInsets(EdgeInsets())
                        .onTapGesture {
                            self.mp3Cacher.removeMp3(cachedMp3: cachedMp3)
                        }
                    }
                    .searchable(text: $searchText)
                    .onChange(of: searchText) { _, newValue in
                        UserDefaults.standard.set(newValue, forKey: "savedCachedMp3sSearchText")
                    }
                    .refreshable {
                        mp3Cacher.refreshList()
                    }
                    .onAppear {
                        mp3Cacher.refreshList()
                    }
                }
            }
        }
    }
}
