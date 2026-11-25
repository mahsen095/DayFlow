import SwiftUI

struct DFHome: View {

    @ObservedObject var store: DFStore
    @Binding var tab: DFTab

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning," }
        if hour < 17 { return "Good afternoon," }
        return "Good evening,"
    }

    private var waterProgress: Double {
        min(Double(store.water) / Double(max(store.waterGoal, 1)), 1)
    }

    private var habitProgress: Double {
        Double(store.completedHabits) / Double(max(store.habits.count, 1))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 25) {

                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(greeting)
                            .font(.system(size: 13))
                            .foregroundStyle(DF.muted)

                        Text("Make today beautiful.")
                            .font(.system(size: 25, weight: .black, design: .rounded))
                            .foregroundStyle(DF.ink)
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .fill(DF.lavender)
                            .frame(width: 48, height: 48)

                        Image(systemName: "sparkles")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(DF.purple)
                    }
                }

                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: 0x4A365F),
                                    Color(hex: 0x795D9B),
                                    Color(hex: 0xA18BD0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Circle()
                        .fill(.white.opacity(0.07))
                        .frame(width: 190, height: 190)
                        .offset(x: 65, y: -75)

                    Circle()
                        .stroke(.white.opacity(0.13), lineWidth: 1)
                        .frame(width: 150, height: 150)
                        .offset(x: 25, y: -40)

                    VStack(alignment: .leading, spacing: 17) {
                        HStack {
                            DFTag(title: "YOUR DAILY SPACE", color: .white)
                                .background(.white.opacity(0.15))
                                .clipShape(Capsule())

                            Spacer()

                            Image(systemName: "sun.max.fill")
                                .font(.system(size: 27))
                                .foregroundStyle(DF.yellow)
                        }

                        Text("A little progress\nis still progress.")
                            .font(.system(size: 27, weight: .black, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Build good habits. Enjoy the little things.")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.78))

                        HStack {
                            Label("\(store.completedTasks) tasks done", systemImage: "checkmark.circle.fill")
                            Spacer()
                            Text(Date.now.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                        }
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding(21)
                }
                .frame(height: 235)
                .clipShape(RoundedRectangle(cornerRadius: 28))

                DFSection(title: "Your little wins", detail: "TODAY")

                HStack(spacing: 12) {
                    miniStat(
                        title: "Tasks",
                        value: "\(store.completedTasks)",
                        icon: "checkmark",
                        color: DF.green,
                        background: DF.mint
                    )

                    miniStat(
                        title: "Workouts",
                        value: "\(store.sessions)",
                        icon: "figure.run",
                        color: DF.purple,
                        background: DF.lavender
                    )

                    miniStat(
                        title: "Water",
                        value: "\(store.water)",
                        icon: "drop.fill",
                        color: DF.blueColor,
                        background: Color(hex: 0xDCEEFF)
                    )
                }

                DFCard {
                    HStack(spacing: 17) {
                        DFRing(
                            progress: habitProgress,
                            color: DF.green,
                            size: 91,
                            lineWidth: 9
                        )

                        VStack(alignment: .leading, spacing: 7) {
                            Text("Daily habits")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(DF.ink)

                            Text("\(store.completedHabits) of \(store.habits.count) habits completed")
                                .font(.system(size: 12))
                                .foregroundStyle(DF.muted)

                            Text(habitProgress >= 1 ? "Amazing work today!" : "Keep your momentum going.")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(DF.green)
                        }

                        Spacer()
                    }
                }

                DFCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 7) {
                            Text("Hydration")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(DF.ink)

                            Text("\(store.water) of \(store.waterGoal) glasses")
                                .font(.system(size: 12))
                                .foregroundStyle(DF.muted)
                        }

                        Spacer()

                        Image(systemName: "drop.fill")
                            .font(.system(size: 25))
                            .foregroundStyle(DF.blueColor)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color(hex: 0xE9F0F7))
                            Capsule()
                                .fill(DF.blueColor)
                                .frame(width: geo.size.width * waterProgress)
                        }
                    }
                    .frame(height: 9)
                    .padding(.vertical, 8)

                    HStack {
                        Text("Keep sipping throughout your day.")
                            .font(.system(size: 10))
                            .foregroundStyle(DF.muted)

                        Spacer()

                        Button {
                            store.water += 1
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 34, height: 34)
                                .background(DF.blueColor)
                                .clipShape(Circle())
                        }
                    }
                }

                DFSection(title: "Coming up", detail: "YOUR REMINDERS")

                if store.tasks.filter({ !$0.completed }).isEmpty {
                    DFCard {
                        HStack(spacing: 12) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 25))
                                .foregroundStyle(DF.purple)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("A clear mind starts here")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(DF.ink)

                                Text("Add a reminder to plan your day.")
                                    .font(.system(size: 11))
                                    .foregroundStyle(DF.muted)
                            }

                            Spacer()

                            Button {
                                tab = .tasks
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 25))
                                    .foregroundStyle(DF.purple)
                            }
                        }
                    }
                } else {
                    ForEach(
                        Array(store.tasks.filter { !$0.completed }.sorted { $0.date < $1.date }.prefix(3))
                    ) { task in
                        Button {
                            tab = .tasks
                        } label: {
                            DFTaskRow(task: task, toggle: {
                                store.toggleTask(task)
                            })
                        }
                        .buttonStyle(.plain)
                    }
                }

                DFSection(title: "Explore your space")

                HStack(spacing: 12) {
                    quickLaunch("Move", "figure.run", DF.coral) {
                        tab = .exercise
                    }

                    quickLaunch("Tools", "calculator.fill", DF.purple) {
                        tab = .tools
                    }

                    quickLaunch("Habits", "leaf.fill", DF.green) {
                        tab = .profile
                    }
                }

                Text("Take it one day at a time.")
                    .font(.system(size: 12, weight: .medium, design: .serif))
                    .italic()
                    .foregroundStyle(DF.muted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
            }
            .padding(.horizontal, 19)
            .padding(.top, 15)
            .padding(.bottom, 20)
        }
    }

    private func miniStat(
        title: String,
        value: String,
        icon: String,
        color: Color,
        background: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 34, height: 34)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: 11))

            Text(value)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(DF.ink)

            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(DF.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .background(DF.paper)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func quickLaunch(
        _ title: String,
        _ icon: String,
        _ color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 11) {
                Image(systemName: icon)
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundStyle(color)

                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(DF.ink)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(DF.paper)
            .clipShape(RoundedRectangle(cornerRadius: 19))
        }
        .buttonStyle(.plain)
    }
}
