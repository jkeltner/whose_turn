import SwiftUI

struct AddTransactionSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let friend: Friend

    @State private var desc = ""
    @State private var date = Date()
    @State private var whoPaid: WhoPaid = .user

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    DatePicker("Date", selection: $date, in: ...Date(), displayedComponents: .date)

                    TextField("Description (e.g., Dinner at Italian restaurant)", text: $desc)
                }

                Section("Who Paid?") {
                    Picker("Who Paid", selection: $whoPaid) {
                        Text("You").tag(WhoPaid.user)
                        Text(friend.name).tag(WhoPaid.friend)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { save() }
                        .disabled(desc.trimmingCharacters(in: .whitespaces).count < 3)
                }
            }
        }
    }

    private func save() {
        let transaction = Transaction(
            friend: friend,
            desc: desc.trimmingCharacters(in: .whitespaces),
            date: date,
            whoPaid: whoPaid
        )
        modelContext.insert(transaction)
        try? modelContext.save()
        dismiss()
    }
}
