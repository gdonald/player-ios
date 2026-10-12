
import SwiftUI

struct CachedMp3ListItem: View {
    let theme: Theme
    let cachedMp3: CachedMp3
    let networkManager: NetworkManager

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "trash")
                .font(.system(size: 11))
                .foregroundStyle(theme.displayDim)

            Text(cachedMp3.nameForList(networkManager: networkManager))
                .font(Theme.text(13, relativeTo: .body))
                .foregroundStyle(theme.listText)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .listRowLine(theme)
    }
}
