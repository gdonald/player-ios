
import SwiftUI

struct ThemePicker: View {
    @EnvironmentObject var themeStore: ThemeStore
    let networkManager: NetworkManager

    var body: some View {
        let theme = themeStore.theme

        Menu {
            ForEach(Theme.all) { choice in
                Button {
                    themeStore.select(choice, using: networkManager)
                } label: {
                    if choice == theme {
                        Label(choice.label, systemImage: "checkmark")
                    } else {
                        Text(choice.label)
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(theme.label.uppercased())
                Image(systemName: "chevron.down")
                    .font(.system(size: 7, weight: .bold))
            }
            .font(Theme.text(9, weight: .bold, relativeTo: .caption2))
            .foregroundStyle(theme.titleText)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(theme.titleBackground)
            .overlay(Rectangle().stroke(theme.titleStripe ?? theme.bevelDark, lineWidth: 1))
        }
        .accessibilityLabel("Theme")
    }
}
