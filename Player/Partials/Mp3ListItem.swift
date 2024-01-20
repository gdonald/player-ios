
import SwiftUI

struct Mp3ListItem: View {
    var mp3: Mp3

    var body: some View {
        VStack(spacing: 0) {
            Text(mp3.title)
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(2)
            Text(mp3.artist_name)
                .font(.system(size: 11))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(3)
        }.padding(5)
    }
}
