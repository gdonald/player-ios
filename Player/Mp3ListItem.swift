
import SwiftUI

struct Mp3ListItem: View {
    var mp3: Mp3

    var body: some View {
        VStack(spacing: 0) {
            Text(mp3.title)
                .font(.system(size: 17))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(5).padding(.leading, 6)

            Text(mp3.artist_name)
                .font(.system(size: 13))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(5).padding(.leading, 6)
        }
        .padding(5)
    }
}
