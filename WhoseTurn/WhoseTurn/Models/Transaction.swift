import Foundation
import SwiftData

enum WhoPaid: String, Codable, CaseIterable {
    case user = "You"
    case friend = "Friend"
}

@Model
final class Transaction {
    var friend: Friend?
    var desc: String
    var date: Date
    var whoPaid: WhoPaid
    var createdAt: Date

    init(friend: Friend, desc: String, date: Date = Date(), whoPaid: WhoPaid) {
        self.friend = friend
        self.desc = desc
        self.date = date
        self.whoPaid = whoPaid
        self.createdAt = Date()
    }
}
