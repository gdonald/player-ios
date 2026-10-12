
import SwiftUI

@main
struct PlayerApp: App {
    @StateObject private var userAuth = UserAuth()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(userAuth)
        }
    }
}
