
import SwiftUI

struct QueuedMp3ListItem: View {
    var queuedMp3: QueuedMp3

    var body: some View {
        VStack(spacing: 0) {
            Text(queuedMp3.mp3.title)
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(2)
            Text(String(queuedMp3.position))
                .font(.system(size: 11))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(3)
        }.padding(0)
    }
}

// #Preview {
//    QueuedMp3ListItem()
// }
