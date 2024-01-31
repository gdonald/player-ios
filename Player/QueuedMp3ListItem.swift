
import SwiftUI

struct QueuedMp3ListItem: View {
    let queuedMp3: QueuedMp3
    let currentMp3: QueuedMp3?

    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "trash")
                .resizable()
                .scaledToFit()
                .frame(width: 15, height: 15)
                .padding(5)

            Text(queuedMp3.mp3.title)
                .font(.system(size: 17))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(5).padding(.leading, 6)

            Spacer()

            if queuedMp3 == currentMp3 {
                Image(systemName: "arrow.left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .padding(5).padding(.trailing, 6)
            }
        }.padding(5)
    }
}
