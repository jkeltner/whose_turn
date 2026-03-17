import SwiftUI
import SwiftData

@main
struct WhoseTurnApp: App {
    var body: some Scene {
        WindowGroup {
            FriendsListView()
        }
        .modelContainer(for: [Friend.self, Transaction.self])
    }
}
