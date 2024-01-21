
import SwiftUI

struct Mp3sView: View {
    @ObservedObject var networkManager: NetworkManager

    var body: some View {
        NavigationView {
            List(networkManager.mp3s) { mp3 in
                Mp3ListItem(mp3: mp3)
                    .listRowInsets(EdgeInsets())
            }
            .listStyle(PlainListStyle())
        }
        .padding(0)
    }
}
