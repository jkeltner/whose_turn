import SwiftUI

struct TransactionHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    let friend: Friend

    private var sortedTransactions: [Transaction] {
        friend.transactions.sorted { $0.date > $1.date }
    }

    var body: some View {
        Group {
            if friend.transactions.isEmpty {
                ContentUnavailableView(
                    "No Transactions Yet",
                    systemImage: "clock",
                    description: Text("Tap on \(friend.name) from the main screen to add one")
                )
            } else {
                List {
                    ForEach(sortedTransactions) { transaction in
                        TransactionRow(transaction: transaction, friendName: friend.name)
                    }
                    .onDelete(perform: deleteTransactions)
                }
            }
        }
        .navigationTitle("History — \(friend.name)")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func deleteTransactions(at offsets: IndexSet) {
        let sorted = sortedTransactions
        for index in offsets {
            modelContext.delete(sorted[index])
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    let friendName: String

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Circle()
                .fill(transaction.whoPaid == .user ? Color.blue.opacity(0.15) : Color.orange.opacity(0.15))
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: transaction.whoPaid == .user ? "person.fill" : "person")
                        .foregroundStyle(transaction.whoPaid == .user ? .blue : .orange)
                        .font(.caption)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.desc)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(transaction.date, format: .dateTime.month().day().year())
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(transaction.whoPaid == .user ? "You paid" : "\(friendName) paid")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(transaction.whoPaid == .user ? Color.blue.opacity(0.1) : Color.orange.opacity(0.1))
                    .foregroundStyle(transaction.whoPaid == .user ? .blue : .orange)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 2)
    }
}
