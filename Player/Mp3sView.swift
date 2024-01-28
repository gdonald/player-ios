
import SwiftUI

struct Mp3sView: View {
    @ObservedObject var networkManager: NetworkManager
    @State private var searchText = ""
    @State private var showMessage = false
    @State private var message = ""

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
            ZStack {
                VStack {
                    List(filteredItems) { mp3 in
                        Mp3ListItem(mp3: mp3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .listRowInsets(EdgeInsets())
                            .onTapGesture {
                                self.message = "\"\(mp3.title)\"\nadded to queue"
                                self.showMessage = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    self.showMessage = false
                                }
                                DispatchQueue.main.async {
                                    networkManager.createQueuedMp3(mp3Id: String(mp3.id))
                                }
                            }
                    }
                    .searchable(text: $searchText)
                }

                if showMessage {
                    Text(message)
                        .padding(20)
                        .background(Color.black.opacity(0.85))
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                        .transition(.opacity)
                        .animation(.easeInOut, value: showMessage)
                        .zIndex(1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
        }
    }
}
