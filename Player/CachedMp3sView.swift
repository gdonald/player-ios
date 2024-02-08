
import SwiftUI

struct CachedMp3sView: View {
    @ObservedObject var mp3Cache: Mp3Cache
    @State private var searchText: String = UserDefaults.standard.string(forKey: "savedCachedMp3sSearchText") ?? ""

    var filteredItems: [CachedMp3] {
        if searchText.isEmpty {
            return mp3Cache.cachedMp3s.sorted { $0.id < $1.id }
        } else {
            return mp3Cache.cachedMp3s.filter {
                $0.nameForList().localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.id < $1.id }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    Button(action: {
                        let delayInterval = 0.01
                        for (index, cachedMp3) in self.mp3Cache.cachedMp3s.enumerated() {
                            DispatchQueue.main.asyncAfter(deadline: .now() + delayInterval * Double(index)) {
                                self.mp3Cache.removeMp3(cachedMp3: cachedMp3)
                                self.mp3Cache.refreshList()
                            }
                        }
                    }) {
                        Text("Clear Cache (\(self.mp3Cache.cachedMp3s.count))")
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                    }
                    .background(RoundedRectangle(cornerRadius: 7)
                        .fill(Color.gray))
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.top, 12)

                    List(filteredItems) { cachedMp3 in
                        CachedMp3ListItem(
                            cachedMp3: cachedMp3
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .listRowInsets(EdgeInsets())
                        .onTapGesture {
                            self.mp3Cache.removeMp3(cachedMp3: cachedMp3)
                        }
                    }
                    .searchable(text: $searchText)
                    .onChange(of: searchText) { _, newValue in
                        UserDefaults.standard.set(newValue, forKey: "savedCachedMp3sSearchText")
                    }
                    .refreshable {
                        mp3Cache.refreshList()
                    }
                    .onAppear {
                        mp3Cache.refreshList()
                    }
                }
            }
        }
    }
}
