
import SwiftUI

struct LogoutView: View {
    @EnvironmentObject var userAuth: UserAuth

    func logoutAction() {
        if let data = "".data(using: .utf8) {
            let status = KeychainHelper.save(key: "sessionCookie", data: data)
            if status != 0 {
                print("Failed to clear session cookie")
            }
        }

        userAuth.isAuthenticated = false
    }

    var body: some View {
        Text("Logging out...")
            .onAppear(perform: logoutAction)
    }
}

#Preview {
    LogoutView()
}
