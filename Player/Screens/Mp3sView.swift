
import SwiftUI

struct Mp3sView: View {
    @ObservedObject var mp3sManager = Mp3sManager()

    var body: some View {
        NavigationView {
            List(mp3sManager.mp3s) { mp3 in
                NavigationLink(destination: Mp3View(mp3: mp3)) {
                    Mp3ListItem(mp3: mp3)
                }
            }
            .navigationBarTitle("Mp3s")
        }.onAppear {
            self.mp3sManager.fetch()
        }
    }
}

#Preview {
    Mp3sView()
}
