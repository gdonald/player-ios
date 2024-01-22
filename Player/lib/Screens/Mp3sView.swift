
import SwiftUI

struct Mp3sView: View {
    @ObservedObject var networkManager: NetworkManager
    @State private var searchText = ""

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
        NavigationView {
            VStack {
                List(filteredItems) { mp3 in
                    Mp3ListItem(mp3: mp3)
                        .listRowInsets(EdgeInsets())
                }
                .searchable(text: $searchText)
            }
        }
    }
}
