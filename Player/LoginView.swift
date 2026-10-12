
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userAuth: UserAuth
    @EnvironmentObject var themeStore: ThemeStore
    @State private var baseUrl: String = "https://player.gregdonald.com"
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var saveLogin: Bool = false

    func authenticateUser(username: String, password: String, retryCount: Int = 0) {
        guard let url = URL(string: "\(baseUrl)/api/sessions") else { return }

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

    func storeLogin(saveLogin: Bool, username: String, password: String, baseUrl: String) {
        if let data = baseUrl.data(using: .utf8) {
            if KeychainHelper.save(key: "baseUrl", data: data) != 0 {
                print("Failed to save baseUrl")
            }
        }

        if KeychainHelper.saveBoolean(key: "saveLogin", value: saveLogin) != 0 {
            print("Failed to save saveLogin")
        }

        if saveLogin {
            if let data = username.data(using: .utf8) {
                if KeychainHelper.save(key: "username", data: data) != 0 {
                    print("Failed to save username")
                }
            }

            if let data = password.data(using: .utf8) {
                if KeychainHelper.save(key: "password", data: data) != 0 {
                    print("Failed to save password")
                }
            }
        } else {
            if let data = "".data(using: .utf8) {
                if KeychainHelper.save(key: "username", data: data) != 0 {
                    print("Failed to delete username")
                }
            }

            if let data = "".data(using: .utf8) {
                if KeychainHelper.save(key: "password", data: data) != 0 {
                    print("Failed to delete password")
                }
            }
        }
    }

    func loadStoredLogin() {
        if let receivedData = KeychainHelper.load(key: "baseUrl"),
           let value = String(data: receivedData, encoding: .utf8),
           !value.isEmpty
        {
            baseUrl = value
        }

        if let receivedData = KeychainHelper.load(key: "username"),
           let value = String(data: receivedData, encoding: .utf8)
        {
            username = value
        }

        if let receivedData = KeychainHelper.load(key: "password"),
           let value = String(data: receivedData, encoding: .utf8)
        {
            password = value
        }

        saveLogin = KeychainHelper.loadBoolean(key: "saveLogin") ?? false
    }

    var body: some View {
        let theme = themeStore.theme

        ScrollView {
            WinampWindow(theme: theme, title: "Login") {
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        FormLabel(theme: theme, text: "Base URL")
                        LCDField(theme: theme, prompt: "https://", text: $baseUrl)
                            .keyboardType(.URL)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        FormLabel(theme: theme, text: "Username")
                        LCDField(theme: theme, prompt: "Username", text: $username)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        FormLabel(theme: theme, text: "Password")
                        LCDField(theme: theme, prompt: "Password", text: $password, secure: true)
                    }

                    HStack {
                        Toggle("Remember", isOn: $saveLogin)
                            .toggleStyle(WinampToggleStyle(theme: theme))

                        Spacer()

                        Button("Login") {
                            storeLogin(saveLogin: saveLogin, username: username, password: password, baseUrl: baseUrl)
                            authenticateUser(username: username, password: password)
                        }
                        .buttonStyle(BevelButtonStyle(theme: theme))
                    }
                }
            }
            .padding(6)
            .padding(.top, 40)
        }
        .onAppear(perform: loadStoredLogin)
    }
}

#Preview {
    LoginView()
        .environmentObject(UserAuth())
        .environmentObject(ThemeStore())
}
