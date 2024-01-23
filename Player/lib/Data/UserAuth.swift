
import Combine
import SwiftUI

class UserAuth: ObservableObject {
    @Published var isAuthenticated: Bool = false

    init() {
        guard let url = URL(string: "\(Constants.baseUrl)/sessions/active.json") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let receivedData = KeychainHelper.load(key: "sessionCookie"),
           let value = String(data: receivedData, encoding: .utf8)
        {
            request.setValue("_player_session=\(value)", forHTTPHeaderField: "Cookie")
        }

        URLSession.shared.dataTask(with: request) { [weak self] _, response, _ in
            DispatchQueue.main.async {
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    return
                }

                if httpResponse.statusCode == 200 {
                    self?.isAuthenticated = true
                } else {
                    print("Auth failed, HTTP Status Code: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
}
