
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userAuth: UserAuth
    @State private var username: String = "gd"
    @State private var password: String = "changeme"

    func authenticateUser(username: String, password: String, retryCount: Int = 0) {
        guard let url = URL(string: "\(Constants.baseUrl)/sessions") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "username": username,
            "password": password
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("Login request failed: \(error), retryCount: \(retryCount)")

                if retryCount < Constants.maxRetryAttempts {
                    let delay = Constants.initialDelayInSeconds * Int(pow(2.0, Double(retryCount)))
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay)) {
                        self.authenticateUser(
                            username: username,
                            password: password,
                            retryCount: retryCount + 1
                        )
                    }
                } else {
                    print("Max login request retries reached.")
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        userAuth.isAuthenticated = true
                    }
                } else {
                    print("Login failed, HTTP Status Code: \(httpResponse.statusCode)")
                }

                if let url = httpResponse.url {
                    let cookies = HTTPCookieStorage.shared.cookies(for: url) ?? []
                    for cookie in cookies {
                        if cookie.name == "_player_session" {
                            DispatchQueue.main.async {
                                if let data = cookie.value.data(using: .utf8) {
                                    if KeychainHelper.save(key: "sessionCookie", data: data) != 0 {
                                        print("Failed to save session cookie")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        task.resume()
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("Login").font(.title)

                TextField("Username", text: $username)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )

                SecureField("Password", text: $password)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )

                Button(action: {
                    authenticateUser(username: username, password: password)
                }) {
                    Text("Login")
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
            .padding(50)
        }
    }
}

#Preview {
    LoginView()
}
