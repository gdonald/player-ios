
import SwiftUI

struct CachedMp3ListItem: View {
    let cachedMp3: CachedMp3
    let networkManager: NetworkManager

    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "trash")
                .resizable()
                .scaledToFit()
                .frame(width: 15, height: 15)
                .padding(5)

            Text(cachedMp3.nameForList(networkManager: networkManager))
                .font(.system(size: 17))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(5).padding(.leading, 6)

        }.padding(5)
    }
}
