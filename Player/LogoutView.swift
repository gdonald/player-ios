
import SwiftUI

struct LogoutView: View {
    @EnvironmentObject var userAuth: UserAuth
    @EnvironmentObject var themeStore: ThemeStore

    func logoutAction() {
        DispatchQueue.main.async {
            if let data = "".data(using: .utf8) {
                if KeychainHelper.save(key: "sessionCookie", data: data) != 0 {
                    print("Failed to clear session cookie")
                }
            }

            self.userAuth.isAuthenticated = false
        }
    }

    var body: some View {
        let theme = themeStore.theme

        VStack {
            WinampWindow(theme: theme, title: "Logout") {
                VStack(spacing: 10) {
                    Text("Are you sure?")
                        .font(Theme.text(13, relativeTo: .body))
                        .foregroundStyle(theme.display)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .lcdPanel(theme)

                    HStack {
                        Spacer()

                        Button("Logout", action: logoutAction)
                            .buttonStyle(BevelButtonStyle(theme: theme))
                    }
                }
            }

            Spacer()
        }
    }
}

#Preview {
    LogoutView()
        .environmentObject(UserAuth())
        .environmentObject(ThemeStore())
}
