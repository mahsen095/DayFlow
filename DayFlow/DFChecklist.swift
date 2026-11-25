import SwiftUI

struct DFChecklist: View {

    @ObservedObject var store: DFStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Your daily rituals")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(DF.ink)

                    Text("\(store.completedHabits) of \(store.habits.count) complete")
                        .font(.system(size: 11))
                        .foregroundStyle(DF.muted)
                }

                Spacer()

                DFRing(
                    progress: Double(store.completedHabits) / Double(max(store.habits.count, 1)),
                    color: DF.green,
                    size: 54,
                    lineWidth: 6
                )
            }

            ForEach(store.habits) { habit in
                Button {
                    store.toggleHabit(habit)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: habit.icon)
                            .font(.system(size: 18))
                            .foregroundStyle(habit.done ? DF.green : DF.purple)
                            .frame(width: 38, height: 38)
                            .background(habit.done ? DF.mint : DF.lavender)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        Text(habit.title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(DF.ink)
                            .strikethrough(habit.done)

                        Spacer()

                        Image(systemName: habit.done ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 21))
                            .foregroundStyle(habit.done ? DF.green : DF.muted)
                    }
                    .padding(11)
                    .background(DF.bg)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .buttonStyle(.plain)
            }

            Button {
                store.resetHabits()
                store.habitDate = Calendar.current.startOfDay(for: Date())
            } label: {
                Text("Reset today's habits")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(DF.purple)
            }
        }
        .padding(17)
        .background(DF.paper)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}
