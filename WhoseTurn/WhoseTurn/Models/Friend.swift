import Foundation
import SwiftData

@Model
final class Friend {
    var name: String
    @Attribute(.externalStorage) var photoData: Data?
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Transaction.friend)
    var transactions: [Transaction] = []

    init(name: String, photoData: Data? = nil) {
        self.name = name
        self.photoData = photoData
        self.createdAt = Date()
    }

    var lastTransaction: Transaction? {
        transactions.sorted { $0.date > $1.date }.first
    }

    var whoseTurn: WhoPaid {
        guard let last = lastTransaction else { return .user }
        return last.whoPaid == .user ? .friend : .user
    }
}
