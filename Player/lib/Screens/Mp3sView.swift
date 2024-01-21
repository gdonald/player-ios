
import SwiftUI

struct Mp3sView: View {
    let mp3s: [Mp3]

    var body: some View {
        NavigationView {
            List(mp3s) { mp3 in
                NavigationLink(destination: Mp3View(mp3: mp3)) {
                    Mp3ListItem(mp3: mp3)
                }
                .listRowInsets(EdgeInsets())
            }
            .listStyle(PlainListStyle())
        }
        .padding(0)
    }
}

#Preview {
    Mp3sView(mp3s: [])
}
