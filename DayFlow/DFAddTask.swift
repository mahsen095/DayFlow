import SwiftUI

struct DFAddTask: View {

    @ObservedObject var store: DFStore
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var date = Calendar.current.date(
        byAdding: .hour,
        value: 1,
        to: Date()
    ) ?? Date()

    @State private var error = false

    var body: some View {
        NavigationStack {
            ZStack {
                DF.bg.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 22) {
                    DFHeader(
                        eyebrow: "NEW REMINDER",
                        title: "What's on\nyour mind?",
                        subtitle: "Make sure you don't forget it."
                    )

                    VStack(alignment: .leading, spacing: 10) {
                        Text("REMINDER TITLE")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.5)
                            .foregroundStyle(DF.muted)

                        TextField("e.g. Finish my project", text: $title)
                            .font(.system(size: 15, weight: .medium))
                            .padding(17)
                            .background(DF.paper)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("DATE AND TIME")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.5)
                            .foregroundStyle(DF.muted)

                        DatePicker(
                            "Reminder time",
                            selection: $date,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                        .padding(17)
                        .background(DF.paper)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    DFCard {
                        Label("Local notification", systemImage: "bell.badge.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(DF.purple)

                        Text("DayFlow can notify you at your selected time. Allow notifications when iOS asks.")
                            .font(.system(size: 12))
                            .foregroundStyle(DF.muted)
                            .padding(.top, 5)
                    }

                    Spacer()

                    DFPrimaryButton(title: "Save Reminder", icon: "checkmark") {
                        let clean = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !clean.isEmpty else {
                            error = true
                            return
                        }

                        DFNotifications.request()
                        store.addTask(clean, date)
                        dismiss()
                    }
                }
                .padding(22)
            }
            .navigationTitle("Create Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(DF.purple)
                }
            }
            .alert("Please enter a title", isPresented: $error) {
                Button("OK", role: .cancel) {}
            }
        }
    }
}
