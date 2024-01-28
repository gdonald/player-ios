
import Combine
import SwiftUI

class UserAuth: ObservableObject {
    @Published var isAuthenticated: Bool = false

    init() {
        checkActiveSession()
    }

    func checkActiveSession(retryCount: Int = 0) {
        guard let url = URL(string: "\(Constants.baseUrl)/sessions/active.json") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let receivedData = KeychainHelper.load(key: "sessionCookie"),
           let value = String(data: receivedData, encoding: .utf8)
        {
            request.setValue("_player_session=\(value)", forHTTPHeaderField: "Cookie")
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] _, response, error in

            if let error = error {
                print("Check active session request failed: \(error), retryCount: \(retryCount)")

                if retryCount < Constants.maxRetryAttempts {
                    let delay = Constants.initialDelayInSeconds * Int(pow(2.0, Double(retryCount)))
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay)) {
                        self?.checkActiveSession(retryCount: retryCount + 1)
                    }
                } else {
                    print("Max check active session retries reached.")
                }
                return
            }

            DispatchQueue.main.async {
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Check active session invalid response")
                    return
                }

                if httpResponse.statusCode == 200 {
                    self?.isAuthenticated = true
                } else {
                    print("Check active session auth failed, HTTP Status Code: \(httpResponse.statusCode)")
                }
            }
        }
        task.resume()
    }
}
