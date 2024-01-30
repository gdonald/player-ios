
import SwiftUI

struct LogoutView: View {
    @EnvironmentObject var userAuth: UserAuth

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
        VStack {
            Text("Are you sure?").padding().font(.title)
            Button(action: self.logoutAction) {
                Text("Logout")
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }
            .background(RoundedRectangle(cornerRadius: 7)
                .fill(Color.gray))
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
    }
}

#Preview {
    LogoutView()
}
