import SwiftUI

struct FriendDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let friend: Friend
    @State private var showingAddTransaction = false
    @State private var showingEditFriend = false

    private var recentTransactions: [Transaction] {
        friend.transactions
            .sorted { $0.date > $1.date }
            .prefix(5)
            .map { $0 }
    }

    var body: some View {
        List {
            // Friend header
            Section {
                HStack(spacing: 12) {
                    if let photoData = friend.photoData,
                       let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 56, height: 56)
                            .foregroundStyle(.gray.opacity(0.5))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(friend.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                        TurnBadge(whoseTurn: friend.whoseTurn, friendName: friend.name)
                    }
                }
                .padding(.vertical, 4)
            }

            // Recent transactions
            Section {
                if friend.transactions.isEmpty {
                    Text("No transactions yet — tap + to add one")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(recentTransactions) { transaction in
                        TransactionRow(transaction: transaction, friendName: friend.name)
                    }
                    .onDelete(perform: deleteTransactions)

                    if friend.transactions.count > 5 {
                        NavigationLink {
                            TransactionHistoryView(friend: friend)
                        } label: {
                            Text("View all \(friend.transactions.count) transactions")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Recent")
                    Spacer()
                    Button(action: { showingAddTransaction = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.green)
                            .font(.title3)
                    }
                }
            }

            // Full history link (always show if there are any transactions)
            if !friend.transactions.isEmpty && friend.transactions.count <= 5 {
                Section {
                    NavigationLink {
                        TransactionHistoryView(friend: friend)
                    } label: {
                        Label("View Full History", systemImage: "clock")
                    }
                }
            }
        }
        .navigationTitle(friend.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button(action: { showingEditFriend = true }) {
                Image(systemName: "pencil")
            }
        }
        .sheet(item: Binding<Friend?>(
            get: { showingEditFriend ? friend : nil },
            set: { _ in showingEditFriend = false }
        )) { friend in
            NavigationStack {
                EditFriendView(friend: friend)
            }
        }


        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionSheet(friend: friend)
        }
    }

    private func deleteTransactions(at offsets: IndexSet) {
        let recent = recentTransactions
        for index in offsets {
            modelContext.delete(recent[index])
        }
    }
}
