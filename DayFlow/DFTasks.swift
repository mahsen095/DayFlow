import SwiftUI

struct DFTasks: View {

    @ObservedObject var store: DFStore
    @State private var showAdd = false
    @State private var completedFilter = false

    private var displayed: [DFTask] {
        store.tasks
            .filter { $0.completed == completedFilter }
            .sorted { $0.date < $1.date }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 23) {

                DFHeader(
                    eyebrow: "YOUR PERSONAL PLANNER",
                    title: "Make room\nfor what matters.",
                    subtitle: "One task at a time. You've got this."
                )

                HStack(spacing: 12) {
                    taskCount("All tasks", "\(store.tasks.count)", DF.purple)
                    taskCount("To do", "\(store.pendingTasks)", DF.coral)
                    taskCount("Done", "\(store.completedTasks)", DF.green)
                }

                Button {
                    showAdd = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("A new beginning")
                                .font(.system(size: 19, weight: .black))
                                .foregroundStyle(.white)

                            Text("Add something to your day.")
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.8))
                        }

                        Spacer()

                        Image(systemName: "plus")
                            .font(.system(size: 19, weight: .bold))
                            .foregroundStyle(DF.purple)
                            .frame(width: 45, height: 45)
                            .background(.white)
                            .clipShape(Circle())
                    }
                    .padding(20)
                    .background(
                        LinearGradient(
                            colors: [DF.purple, DF.violet],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                }
                .buttonStyle(.plain)

                HStack(spacing: 10) {
                    filterButton("To do", false)
                    filterButton("Completed", true)
                }

                DFSection(
                    title: completedFilter ? "Finished tasks" : "Your tasks",
                    detail: "\(displayed.count) ITEMS"
                )

                if displayed.isEmpty {
                    DFCard {
                        VStack(spacing: 12) {
                            Image(systemName: completedFilter ? "checkmark.seal" : "tray")
                                .font(.system(size: 38))
                                .foregroundStyle(DF.purple)

                            Text(completedFilter ? "Nothing completed yet" : "Nothing on your list")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(DF.ink)

                            Text("Your tasks will appear here.")
                                .font(.system(size: 12))
                                .foregroundStyle(DF.muted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 25)
                    }
                }

                ForEach(displayed) { task in
                    DFTaskRow(task: task) {
                        store.toggleTask(task)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            store.deleteTask(task)
                        } label: {
                            Label("Delete Reminder", systemImage: "trash")
                        }
                    }
                }

                Text("Your reminders are stored locally on this device.")
                    .font(.system(size: 11))
                    .foregroundStyle(DF.muted)
                    .frame(maxWidth: .infinity)
            }
            .padding(19)
            .padding(.top, 15)
        }
        .sheet(isPresented: $showAdd) {
            DFAddTask(store: store)
        }
    }

    private func taskCount(_ title: String, _ value: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(value)
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(color)

            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(DF.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(DF.paper)
        .clipShape(RoundedRectangle(cornerRadius: 17))
    }

    private func filterButton(_ title: String, _ value: Bool) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                completedFilter = value
            }
        } label: {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(completedFilter == value ? .white : DF.muted)
                .frame(maxWidth: .infinity)
                .padding(13)
                .background(completedFilter == value ? DF.ink : DF.paper)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct DFTaskRow: View {

    let task: DFTask
    let toggle: () -> Void

    var body: some View {
        HStack(spacing: 13) {
            Button(action: toggle) {
                Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 25))
                    .foregroundStyle(task.completed ? DF.green : DF.purple)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(DF.ink)
                    .strikethrough(task.completed)

                HStack(spacing: 5) {
                    Image(systemName: "calendar")
                    Text(task.date.formatted(date: .abbreviated, time: .shortened))
                }
                .font(.system(size: 10))
                .foregroundStyle(DF.muted)
            }

            Spacer()

            if !task.completed {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 17))
                    .foregroundStyle(DF.coral)
            }
        }
        .padding(16)
        .background(DF.paper)
        .clipShape(RoundedRectangle(cornerRadius: 19))
    }
}
