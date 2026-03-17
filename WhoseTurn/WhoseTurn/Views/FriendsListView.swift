import SwiftUI
import SwiftData

struct FriendsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Friend.name) private var friends: [Friend]
    @State private var showingAddFriend = false
    @State private var friendToEdit: Friend?
    @State private var friendForHistory: Friend?

    var body: some View {
        NavigationStack {
            Group {
                if friends.isEmpty {
                    emptyState
                } else {
                    friendsList
                }
            }
            .navigationTitle("Whose Turn")
            .toolbar {
                Button(action: { showingAddFriend = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddFriend) {
                AddFriendView()
            }
            .sheet(item: $friendToEdit) { friend in
                NavigationStack {
                    EditFriendView(friend: friend)
                }
            }
            .navigationDestination(for: Friend.self) { friend in
                FriendDetailView(friend: friend)
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Friends Yet",
            systemImage: "person.2",
            description: Text("Tap the + button to add your first friend")
        )
    }

    private var friendsList: some View {
        List {
            ForEach(friends) { friend in
                NavigationLink(value: friend) {
                    FriendRow(friend: friend)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        modelContext.delete(friend)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    Button {
                        friendToEdit = friend
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.orange)
                }
            }
        }
    }
}

struct FriendRow: View {
    let friend: Friend

    var body: some View {
        HStack(spacing: 12) {
            // Photo
            if let photoData = friend.photoData,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 44, height: 44)
                    .foregroundStyle(.gray.opacity(0.5))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(friend.name)
                    .font(.headline)

                // Last meeting info
                if let last = friend.lastTransaction {
                    Text("\(last.date, format: .dateTime.month().day().year()) — \(last.desc)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("No meetings yet")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Whose turn badge
                TurnBadge(whoseTurn: friend.whoseTurn, friendName: friend.name)
            }
        }
        .padding(.vertical, 4)
    }
}

struct TurnBadge: View {
    let whoseTurn: WhoPaid
    let friendName: String

    var body: some View {
        Text(whoseTurn == .user ? "Your turn to pay" : "\(friendName)'s turn to pay")
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(whoseTurn == .user ? Color.blue.opacity(0.15) : Color.orange.opacity(0.15))
            .foregroundStyle(whoseTurn == .user ? .blue : .orange)
            .clipShape(Capsule())
    }
}
