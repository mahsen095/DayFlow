
import SwiftUI
import UserNotifications
import Combine

// MARK: - APP ENTRY

@main
struct DayFlowApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - THEME

enum DF {
    static let bg = Color(hex: 0xF8e580)
    static let paper = Color(hex: 0xFFFEFC)
    static let ink = Color(hex: 0x282139)
    static let muted = Color(hex: 0x96909F)
    static let purple = Color(hex: 0x8065D9)
    static let violet = Color(hex: 0xA38BEE)
    static let lavender = Color(hex: 0xEDE6FF)
    static let peach = Color(hex: 0xFFE1D4)
    static let coral = Color(hex: 0xF28B75)
    static let mint = Color(hex: 0xD9F1E5)
    static let green = Color(hex: 0x50AC83)
    static let yellow = Color(hex: 0xF5D98A)
    static let navy = Color(hex: 0x302747)
    static let line = Color(hex: 0xEEE9E5)
}

extension Color {
    init(hex: UInt) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 255) / 255,
            green: Double((hex >> 8) & 255) / 255,
            blue: Double(hex & 255) / 255,
            opacity: 1
        )
    }
}

// MARK: - MODELS

struct DFTask: Identifiable, Codable {
    var id = UUID()
    var title: String
    var date: Date
    var completed = false
}

struct DFNote: Identifiable, Codable {
    var id = UUID()
    var title: String
    var body: String
    var date = Date()
}

struct DFWorkout: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let minutes: Int
    let description: String
    let icon: String
    let color: Color
    let exercises: [String]
}

struct DFHabit: Identifiable, Codable {
    var id: String
    var title: String
    var icon: String
    var done: Bool
}

// MARK: - STORE

final class DFStore: ObservableObject {

    @Published var tasks: [DFTask] = [] {
        didSet { save(tasks, "tasks") }
    }

    @Published var notes: [DFNote] = [] {
        didSet { save(notes, "notes") }
    }

    @Published var water = 0 {
        didSet { saveValue(water, "water") }
    }

    @Published var waterGoal = 8 {
        didSet { saveValue(waterGoal, "waterGoal") }
    }

    @Published var sessions = 0 {
        didSet { saveValue(sessions, "sessions") }
    }

    @Published var workoutMinutes = 0 {
        didSet { saveValue(workoutMinutes, "workoutMinutes") }
    }

    @Published var habits: [DFHabit] = [] {
        didSet { save(habits, "habits") }
    }

    @Published var waterDate = Calendar.current.startOfDay(for: Date()) {
        didSet { saveValue(waterDate, "waterDate") }
    }

    @Published var habitDate = Calendar.current.startOfDay(for: Date()) {
        didSet { saveValue(habitDate, "habitDate") }
    }

    init() {
        tasks = load([DFTask].self, "tasks") ?? []
        notes = load([DFNote].self, "notes") ?? []
        habits = load([DFHabit].self, "habits") ?? []

        water = loadValue("water", default: 0)
        waterGoal = loadValue("waterGoal", default: 8)
        sessions = loadValue("sessions", default: 0)
        workoutMinutes = loadValue("workoutMinutes", default: 0)
        waterDate = loadValue("waterDate", default: Calendar.current.startOfDay(for: Date()))
        habitDate = loadValue("habitDate", default: Calendar.current.startOfDay(for: Date()))

        resetDailyValuesIfNeeded()
        if habits.isEmpty {
            resetHabits()
        }
    }

    private func save<T: Encodable>(_ value: T, _ key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: "df.\(key)")
        }
    }

    private func load<T: Decodable>(_ type: T.Type, _ key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: "df.\(key)") else {
            return nil
        }
        return try? JSONDecoder().decode(type, from: data)
    }

    private func saveValue<T: Encodable>(_ value: T, _ key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: "df.\(key)")
        }
    }

    private func loadValue<T: Decodable>(_ key: String, default value: T) -> T {
        guard let data = UserDefaults.standard.data(forKey: "df.\(key)"),
              let result = try? JSONDecoder().decode(T.self, from: data) else {
            return value
        }
        return result
    }

    func resetDailyValuesIfNeeded() {
        let today = Calendar.current.startOfDay(for: Date())

        if waterDate < today {
            waterDate = today
            water = 0
        }

        if habitDate < today {
            habitDate = today
            resetHabits()
            habitDate = today
        }
    }

  
    func resetHabits() {
        habits = [
            DFHabit(id: "wake", title: "Wake up early", icon: "sun.max.fill", done: false),
            DFHabit(id: "water", title: "Drink enough water", icon: "drop.fill", done: false),
            DFHabit(id: "move", title: "Move your body", icon: "figure.run", done: false),
            DFHabit(id: "read", title: "Read something", icon: "book.fill", done: false),
            DFHabit(id: "plan", title: "Plan tomorrow", icon: "calendar", done: false)
        ]
    }
    var completedTasks: Int {
        tasks.filter { $0.completed }.count
    }

    var pendingTasks: Int {
        tasks.filter { !$0.completed }.count
    }

    var completedHabits: Int {
        habits.filter { $0.done }.count
    }

    func addTask(_ title: String, _ date: Date) {
        let task = DFTask(title: title, date: date)
        tasks.append(task)
        DFNotifications.schedule(task)
    }

    func toggleTask(_ task: DFTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }

        tasks[index].completed.toggle()

        if tasks[index].completed {
            DFNotifications.cancel(task.id)
        } else {
            DFNotifications.schedule(tasks[index])
        }
    }

    func deleteTask(_ task: DFTask) {
        tasks.removeAll { $0.id == task.id }
        DFNotifications.cancel(task.id)
    }

    func addNote(_ title: String, _ body: String) {
        notes.insert(DFNote(title: title, body: body), at: 0)
    }

    func toggleHabit(_ habit: DFHabit) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else {
            return
        }
        habits[index].done.toggle()
    }
}

// MARK: - LOCAL NOTIFICATIONS

enum DFNotifications {

    static func request() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { _, _ in }
    }

    static func schedule(_ task: DFTask) {
        guard task.date > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "DayFlow Reminder"
        content.body = task.title
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: task.date
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: task.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    static func cancel(_ id: UUID) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [id.uuidString]
            )
    }
}

// MARK: - MAIN NAVIGATION

enum DFTab: String, CaseIterable {
    case home = "Home"
    case tasks = "Tasks"
    case exercise = "Move"
    case tools = "Tools"
    case profile = "Profile"

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .tasks: return "checkmark.circle.fill"
        case .exercise: return "figure.run"
        case .tools: return "square.grid.2x2.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }
}

struct ContentView: View {

    @StateObject private var store = DFStore()
    @State private var selectedTab: DFTab = .home

    var body: some View {
        ZStack {
            DF.bg.ignoresSafeArea()

            Group {
                switch selectedTab {
                case .home:
                    DFHome(store: store, tab: $selectedTab)
                case .tasks:
                    DFTasks(store: store)
                case .exercise:
                    DFExercise(store: store)
                case .tools:
                    DFTools(store: store)
                case .profile:
                    DFProfile(store: store)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            DFNavigation(selected: $selectedTab)
        }
        .preferredColorScheme(.light)
        .onAppear {
            store.resetDailyValuesIfNeeded()
        }
    }
}

// MARK: - FLOATING NAVIGATION

struct DFNavigation: View {

    @Binding var selected: DFTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(DFTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selected = tab
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 19, weight: .semibold))
                            .frame(height: 23)

                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(selected == tab ? DF.purple : DF.muted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background {
                        if selected == tab {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(DF.lavender)
                                .padding(.horizontal, 5)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .background {
            DF.paper
                .ignoresSafeArea(edges: .bottom)
                .shadow(color: DF.ink.opacity(0.07), radius: 15, y: -5)
        }
    }
}

// MARK: - REUSABLE UI

struct DFHeader: View {
    let eyebrow: String
    let title: String
    var subtitle: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(eyebrow.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundStyle(DF.purple)

            Text(title)
                .font(.system(size: 29, weight: .black, design: .rounded))
                .foregroundStyle(DF.ink)

            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(DF.muted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct DFSection: View {
    let title: String
    var detail: String = ""

    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundStyle(DF.ink)

            Spacer()

            if !detail.isEmpty {
                Text(detail)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DF.muted)
            }
        }
    }
}

struct DFCard<Content: View>: View {
    var padding: CGFloat = 17
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DF.paper)
            .clipShape(RoundedRectangle(cornerRadius: 23))
    }
}

struct DFTag: View {
    let title: String
    var color: Color = DF.purple

    var body: some View {
        Text(title)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

struct DFPrimaryButton: View {
    let title: String
    var icon: String = "arrow.right"
    var color: Color = DF.purple
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))

                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

struct DFRing: View {
    let progress: Double
    let color: Color
    var size: CGFloat = 100
    var lineWidth: CGFloat = 10

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.14), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Text("\(Int(progress * 100))%")
                .font(.system(size: size * 0.21, weight: .black))
                .foregroundStyle(DF.ink)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - HOME DASHBOARD

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

                // Hero panel

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

                // Overview

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

                // Habit progress

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

                // Water

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

                // Upcoming tasks

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

                // Quick launch

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

extension DF {
    static let blueColor = Color(hex: 0x589BD7)
}

// MARK: - TASKS SCREEN

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

                // New task banner

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

// MARK: - ADD TASK

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

// MARK: - WORKOUT DATA

let dfWorkouts: [DFWorkout] = [

    DFWorkout(
        title: "Morning Awakening",
        category: "FLEXIBILITY",
        minutes: 5,
        description: "A gentle routine to wake up your body and start fresh.",
        icon: "sun.max.fill",
        color: DF.coral,
        exercises: [
            "Neck rotations – 30 seconds",
            "Shoulder rolls – 30 seconds",
            "Standing side stretch – 1 minute",
            "Forward fold – 1 minute",
            "Arm stretches – 2 minutes"
        ]
    ),

    DFWorkout(
        title: "Full Body Energy",
        category: "STRENGTH",
        minutes: 10,
        description: "An accessible full-body routine using simple movements.",
        icon: "figure.strengthtraining.traditional",
        color: DF.purple,
        exercises: [
            "March in place – 1 minute",
            "Bodyweight squats – 2 minutes",
            "Wall push-ups – 2 minutes",
            "Standing lunges – 2 minutes",
            "Side steps – 2 minutes",
            "Cool down – 1 minute"
        ]
    ),

    DFWorkout(
        title: "Cardio Flow",
        category: "CARDIO",
        minutes: 8,
        description: "Get your body moving with an easy cardio session.",
        icon: "figure.run",
        color: DF.coral,
        exercises: [
            "March in place – 1 minute",
            "Step jacks – 2 minutes",
            "High knees – 1 minute",
            "Side steps – 2 minutes",
            "Slow walking – 2 minutes"
        ]
    ),

    DFWorkout(
        title: "Core Balance",
        category: "CORE",
        minutes: 12,
        description: "Build core stability with slow and controlled movements.",
        icon: "figure.core.training",
        color: DF.green,
        exercises: [
            "Standing knee raises – 2 minutes",
            "Bird dog – 2 minutes",
            "Dead bug – 2 minutes",
            "Modified plank – 2 minutes",
            "Glute bridge – 2 minutes",
            "Cool down – 2 minutes"
        ]
    ),

    DFWorkout(
        title: "Peaceful Recovery",
        category: "RELAXATION",
        minutes: 6,
        description: "Slow down, stretch and reconnect with your body.",
        icon: "figure.mind.and.body",
        color: DF.blueColor,
        exercises: [
            "Deep breathing – 1 minute",
            "Child's pose – 1 minute",
            "Seated stretch – 1 minute",
            "Cat and cow – 1 minute",
            "Relaxation – 2 minutes"
        ]
    )
]

// MARK: - EXERCISE SCREEN

struct DFExercise: View {

    @ObservedObject var store: DFStore
    @State private var selected: DFWorkout?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {

                DFHeader(
                    eyebrow: "YOUR MOVEMENT STUDIO",
                    title: "Find your\nflow.",
                    subtitle: "A little movement can change your day."
                )

                // Workout featured card

                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 26)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: 0xE7A28B),
                                    Color(hex: 0xF3C2A9),
                                    Color(hex: 0xF9D8BD)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Circle()
                        .fill(.white.opacity(0.25))
                        .frame(width: 180, height: 180)
                        .offset(x: 210, y: -75)

                    VStack(alignment: .leading, spacing: 12) {
                        DFTag(title: "TODAY'S INSPIRATION", color: DF.ink)

                        Image(systemName: "figure.cooldown")
                            .font(.system(size: 43))
                            .foregroundStyle(DF.ink)
                            .padding(.top, 5)

                        Text("Move a little.\nFeel a lot.")
                            .font(.system(size: 27, weight: .black, design: .rounded))
                            .foregroundStyle(DF.ink)

                        Button {
                            selected = dfWorkouts[0]
                        } label: {
                            HStack {
                                Text("Explore workout")
                                Image(systemName: "arrow.right")
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(DF.ink)
                            .clipShape(Capsule())
                        }
                    }
                    .padding(21)
                }
                .frame(height: 255)
                .clipShape(RoundedRectangle(cornerRadius: 26))

                HStack(spacing: 12) {
                    workoutStat("Sessions", "\(store.sessions)", "trophy.fill", DF.purple)
                    workoutStat("Minutes", "\(store.workoutMinutes)", "timer", DF.green)
                }

                DFSection(title: "Your workout collection", detail: "5 ROUTINES")

                ForEach(dfWorkouts) { workout in
                    Button {
                        selected = workout
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 17)
                                    .fill(workout.color.opacity(0.14))

                                Image(systemName: workout.icon)
                                    .font(.system(size: 26, weight: .medium))
                                    .foregroundStyle(workout.color)
                            }
                            .frame(width: 59, height: 59)

                            VStack(alignment: .leading, spacing: 6) {
                                Text(workout.category)
                                    .font(.system(size: 9, weight: .bold))
                                    .tracking(1.2)
                                    .foregroundStyle(workout.color)

                                Text(workout.title)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(DF.ink)

                                Text("\(workout.minutes) minutes • Beginner friendly")
                                    .font(.system(size: 10))
                                    .foregroundStyle(DF.muted)
                            }

                            Spacer()

                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 29))
                                .foregroundStyle(workout.color)
                        }
                        .padding(14)
                        .background(DF.paper)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .buttonStyle(.plain)
                }

                Text("Move at your own pace. Stop if you feel pain, dizziness or unusual discomfort.")
                    .font(.system(size: 11))
                    .foregroundStyle(DF.muted)
                    .padding(.bottom, 10)
            }
            .padding(19)
            .padding(.top, 15)
        }
        .sheet(item: $selected) { workout in
            DFWorkoutDetail(workout: workout, store: store)
        }
    }

    private func workoutStat(
        _ title: String,
        _ value: String,
        _ icon: String,
        _ color: Color
    ) -> some View {
        HStack(spacing: 11) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 3) {
                Text(value)
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(DF.ink)

                Text(title)
                    .font(.system(size: 10))
                    .foregroundStyle(DF.muted)
            }

            Spacer()
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(DF.paper)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: - WORKOUT DETAIL

struct DFWorkoutDetail: View {

    let workout: DFWorkout
    @ObservedObject var store: DFStore
    @Environment(\.dismiss) var dismiss

    @State private var remaining = 0
    @State private var running = false
    @State private var finished = false

    private let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {

                    ZStack {
                        Circle()
                            .fill(workout.color.opacity(0.13))
                            .frame(width: 140, height: 140)

                        Image(systemName: workout.icon)
                            .font(.system(size: 55))
                            .foregroundStyle(workout.color)
                    }
                    .padding(.top, 15)

                    Text(workout.title)
                        .font(.system(size: 27, weight: .black, design: .rounded))
                        .foregroundStyle(DF.ink)

                    Text(workout.description)
                        .font(.system(size: 13))
                        .foregroundStyle(DF.muted)
                        .multilineTextAlignment(.center)

                    DFCard {
                        Text(timeString)
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(DF.ink)
                            .frame(maxWidth: .infinity)

                        Text(finished ? "SESSION COMPLETE" : running ? "KEEP GOING" : "READY WHEN YOU ARE")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(workout.color)
                            .frame(maxWidth: .infinity)
                    }

                    DFSection(title: "Your routine")

                    ForEach(Array(workout.exercises.enumerated()), id: \.offset) { index, exercise in
                        HStack(spacing: 13) {
                            Text(String(format: "%02d", index + 1))
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(workout.color)
                                .frame(width: 37, height: 37)
                                .background(workout.color.opacity(0.12))
                                .clipShape(Circle())

                            Text(exercise)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(DF.ink)

                            Spacer()
                        }
                        .padding(12)
                        .background(DF.paper)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }

                    if !finished {
                        DFPrimaryButton(
                            title: running ? "Pause Session" : remaining == 0 ? "Start Workout" : "Resume Workout",
                            icon: running ? "pause.fill" : "play.fill",
                            color: workout.color
                        ) {
                            if remaining == 0 {
                                remaining = workout.minutes * 60
                            }
                            running.toggle()
                        }
                    } else {
                        DFPrimaryButton(
                            title: "Save My Progress",
                            icon: "checkmark",
                            color: DF.green
                        ) {
                            store.sessions += 1
                            store.workoutMinutes += workout.minutes
                            dismiss()
                        }
                    }
                }
                .padding(20)
            }
            .background(DF.bg)
            .navigationTitle("Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        running = false
                        dismiss()
                    }
                    .foregroundStyle(DF.purple)
                }
            }
            .onReceive(timer) { _ in
                guard running, remaining > 0 else { return }

                remaining -= 1

                if remaining == 0 {
                    running = false
                    finished = true
                }
            }
            .onDisappear {
                running = false
            }
        }
    }

    private var timeString: String {
        String(format: "%02d:%02d", remaining / 60, remaining % 60)
    }
}

// MARK: - UTILITIES

enum DFTool: String, CaseIterable {
    case calculator = "Calculator"
    case notes = "Notes"
    case water = "Water"
    case checklist = "Checklist"

    var icon: String {
        switch self {
        case .calculator: return "calculator"
        case .notes: return "note.text"
        case .water: return "drop.fill"
        case .checklist: return "checklist"
        }
    }

    var color: Color {
        switch self {
        case .calculator: return DF.purple
        case .notes: return DF.coral
        case .water: return DF.blueColor
        case .checklist: return DF.green
        }
    }
}

struct DFTools: View {

    @ObservedObject var store: DFStore
    @State private var selected: DFTool = .calculator

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 23) {

                DFHeader(
                    eyebrow: "YOUR EVERYDAY TOOLKIT",
                    title: "Little tools.\nBig convenience.",
                    subtitle: "Everything you need, in one place."
                )

                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 12
                ) {
                    ForEach(DFTool.allCases, id: \.self) { tool in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selected = tool
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 13) {
                                Image(systemName: tool.icon)
                                    .font(.system(size: 22))
                                    .foregroundStyle(tool.color)
                                    .frame(width: 45, height: 45)
                                    .background(tool.color.opacity(0.13))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))

                                Text(tool.rawValue)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(DF.ink)

                                HStack {
                                    Text(selected == tool ? "OPEN NOW" : "EXPLORE")
                                        .font(.system(size: 9, weight: .bold))
                                        .tracking(1)
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 10, weight: .bold))
                                }
                                .foregroundStyle(tool.color)
                            }
                            .padding(15)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(selected == tool ? tool.color.opacity(0.08) : DF.paper)
                            .overlay {
                                RoundedRectangle(cornerRadius: 19)
                                    .stroke(selected == tool ? tool.color.opacity(0.6) : .clear, lineWidth: 1.3)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 19))
                        }
                        .buttonStyle(.plain)
                    }
                }

                HStack {
                    Text(selected.rawValue)
                        .font(.system(size: 21, weight: .black))
                        .foregroundStyle(DF.ink)

                    Spacer()

                    DFTag(title: "OFFLINE", color: DF.green)
                }

                Group {
                    switch selected {
                    case .calculator:
                        DFCalculator()
                    case .notes:
                        DFNotes(store: store)
                    case .water:
                        DFWater(store: store)
                    case .checklist:
                        DFChecklist(store: store)
                    }
                }
                .id(selected)
            }
            .padding(19)
            .padding(.top, 15)
        }
    }
}

// MARK: - CALCULATOR

struct DFCalculator: View {

    @State private var display = "0"
    @State private var stored: Double?
    @State private var operation: String?
    @State private var reset = false

    private let rows = [
        ["AC", "±", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "−"],
        ["1", "2", "3", "+"],
        ["0", ".", "="]
    ]

    var body: some View {
        VStack(spacing: 11) {
            VStack(alignment: .trailing, spacing: 8) {
                Text("YOUR CALCULATION")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(DF.muted)

                Text(display)
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(DF.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(20)
            .frame(height: 115)
            .background(DF.lavender.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: 19))

            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 9) {
                    ForEach(row, id: \.self) { key in
                        Button {
                            tap(key)
                        } label: {
                            Text(key)
                                .font(.system(size: 19, weight: .bold))
                                .foregroundStyle(foreground(key))
                                .frame(maxWidth: .infinity)
                                .frame(height: 57)
                                .background(background(key))
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(15)
        .background(DF.paper)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private func foreground(_ key: String) -> Color {
        if key == "=" { return .white }
        if ["÷", "×", "−", "+", "%"].contains(key) { return DF.purple }
        if ["AC", "±"].contains(key) { return DF.coral }
        return DF.ink
    }

    private func background(_ key: String) -> Color {
        if key == "=" { return DF.purple }
        if ["÷", "×", "−", "+", "%"].contains(key) { return DF.lavender }
        if ["AC", "±"].contains(key) { return DF.peach }
        return DF.bg
    }

    private func format(_ number: Double) -> String {
        guard number.isFinite else { return "Error" }
        if number.rounded() == number {
            return String(format: "%.0f", number)
        }
        return String(number)
    }

    private func tap(_ key: String) {
        switch key {
        case "AC":
            display = "0"
            stored = nil
            operation = nil
            reset = false

        case "±":
            if let n = Double(display) {
                display = format(-n)
            }

        case "%":
            if let n = Double(display) {
                display = format(n / 100)
            }

        case "+", "−", "×", "÷":
            stored = Double(display) ?? 0
            operation = key
            reset = true

        case "=":
            guard let first = stored,
                  let second = Double(display),
                  let op = operation else { return }

            var result = first

            switch op {
            case "+": result = first + second
            case "−": result = first - second
            case "×": result = first * second
            case "÷":
                guard second != 0 else {
                    display = "Error"
                    stored = nil
                    operation = nil
                    reset = true
                    return
                }
                result = first / second
            default: break
            }

            display = format(result)
            stored = nil
            operation = nil
            reset = true

        case ".":
            if reset {
                display = "0."
                reset = false
            } else if !display.contains(".") {
                display += "."
            }

        default:
            if reset || display == "0" || display == "Error" {
                display = key
                reset = false
            } else if display.count < 15 {
                display += key
            }
        }
    }
}

// MARK: - NOTES

struct DFNotes: View {

    @ObservedObject var store: DFStore
    @State private var title = ""
    @State private var content = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {

            TextField("Give your note a title", text: $title)
                .font(.system(size: 14, weight: .semibold))
                .padding(15)
                .background(DF.bg)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            TextEditor(text: $content)
                .font(.system(size: 14))
                .scrollContentBackground(.hidden)
                .frame(height: 120)
                .padding(10)
                .background(DF.bg)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            DFPrimaryButton(title: "Save Note", icon: "square.and.arrow.down") {
                let clean = content.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !clean.isEmpty || !title.isEmpty else { return }

                store.addNote(
                    title.trimmingCharacters(in: .whitespaces).isEmpty ? "Untitled Note" : title,
                    content
                )
                title = ""
                content = ""
            }

            DFSection(title: "Your saved notes")

            if store.notes.isEmpty {
                Text("Your thoughts will live here.")
                    .font(.system(size: 12))
                    .foregroundStyle(DF.muted)
                    .padding(.vertical, 20)
            }

            ForEach(store.notes) { note in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(note.title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(DF.ink)

                        Spacer()

                        Button(role: .destructive) {
                            store.notes.removeAll { $0.id == note.id }
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(DF.coral)
                        }
                    }

                    Text(note.body)
                        .font(.system(size: 12))
                        .foregroundStyle(DF.muted)

                    Text(note.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 10))
                        .foregroundStyle(DF.purple)
                }
                .padding(15)
                .background(DF.bg)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(17)
        .background(DF.paper)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}

// MARK: - WATER

struct DFWater: View {

    @ObservedObject var store: DFStore

    private var progress: Double {
        min(Double(store.water) / Double(max(store.waterGoal, 1)), 1)
    }

    var body: some View {
        VStack(spacing: 20) {

            ZStack {
                Circle()
                    .fill(Color(hex: 0xE4F1FF))
                    .frame(width: 160, height: 160)

                Circle()
                    .stroke(DF.blueColor.opacity(0.16), lineWidth: 11)
                    .frame(width: 135, height: 135)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        DF.blueColor,
                        style: StrokeStyle(lineWidth: 11, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 135, height: 135)

                VStack(spacing: 5) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(DF.blueColor)

                    Text("\(store.water)")
                        .font(.system(size: 29, weight: .black))
                        .foregroundStyle(DF.ink)

                    Text("GLASSES")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(DF.muted)
                }
            }

            Text("\(store.water) of \(store.waterGoal) glasses")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(DF.ink)

            Text(progress >= 1 ? "Daily goal reached. Well done!" : "Every glass is a small act of care.")
                .font(.system(size: 12))
                .foregroundStyle(DF.muted)

            HStack(spacing: 12) {
                Button {
                    store.water = max(0, store.water - 1)
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(DF.blueColor)
                        .frame(width: 50, height: 50)
                        .background(Color(hex: 0xE4F1FF))
                        .clipShape(Circle())
                }

                Button {
                    store.water += 1
                } label: {
                    Label("Add a glass", systemImage: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 23)
                        .frame(height: 50)
                        .background(DF.blueColor)
                        .clipShape(Capsule())
                }
            }

            Stepper("Daily goal: \(store.waterGoal) glasses", value: $store.waterGoal, in: 1...20)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(DF.ink)

            Button("Reset count") {
                store.water = 0
            }
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(DF.coral)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(DF.paper)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}

// MARK: - DAILY CHECKLIST

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

// MARK: - PROFILE / HABITS SCREEN

struct DFProfile: View {

    @ObservedObject var store: DFStore
    @State private var showReset = false

    private var habitProgress: Double {
        Double(store.completedHabits) / Double(max(store.habits.count, 1))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 23) {

                DFHeader(
                    eyebrow: "YOUR PERSONAL SPACE",
                    title: "Your progress.",
                    subtitle: "Celebrate how far you've come."
                )

                // Profile header

                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(DF.lavender)
                            .frame(width: 70, height: 70)

                        Image(systemName: "person.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(DF.purple)
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text("DayFlow Explorer")
                            .font(.system(size: 18, weight: .black))
                            .foregroundStyle(DF.ink)

                        Text("Your journey, your pace.")
                            .font(.system(size: 12))
                            .foregroundStyle(DF.muted)

                        DFTag(title: "PERSONAL SPACE", color: DF.purple)
                    }

                    Spacer()
                }
                .padding(18)
                .background(DF.paper)
                .clipShape(RoundedRectangle(cornerRadius: 22))

                // Activity summary

                DFSection(title: "Your activity")

                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 12
                ) {
                    profileStat("Completed tasks", "\(store.completedTasks)", "checkmark.circle.fill", DF.green)
                    profileStat("Pending tasks", "\(store.pendingTasks)", "clock.fill", DF.coral)
                    profileStat("Workouts", "\(store.sessions)", "figure.run", DF.purple)
                    profileStat("Active minutes", "\(store.workoutMinutes)", "timer", DF.blueColor)
                }

                DFSection(title: "Daily habits")

                DFCard {
                    HStack {
                        DFRing(
                            progress: habitProgress,
                            color: DF.green,
                            size: 85
                        )

                        VStack(alignment: .leading, spacing: 7) {
                            Text("Your daily consistency")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(DF.ink)

                            Text("\(store.completedHabits) habits completed")
                                .font(.system(size: 11))
                                .foregroundStyle(DF.muted)
                        }

                        Spacer()
                    }
                }

                DFSection(title: "Preferences")

                DFCard(padding: 0) {
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundStyle(DF.blueColor)

                            Text("Daily water goal")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(DF.ink)

                            Spacer()

                            Stepper("\(store.waterGoal)", value: $store.waterGoal, in: 1...20)
                                .labelsHidden()

                            Text("\(store.waterGoal)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(DF.ink)
                        }
                        .padding(16)

                        Divider().padding(.leading, 48)

                        Button {
                            DFNotifications.request()
                        } label: {
                            profileRow("Notification permission", "bell.badge.fill", DF.coral)
                        }

                        Divider().padding(.leading, 48)

                        Button {
                            showReset = true
                        } label: {
                            profileRow("Delete all reminders", "trash.fill", DF.coral)
                        }
                    }
                }

                DFCard {
                    VStack(spacing: 9) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 28))
                            .foregroundStyle(DF.purple)

                        Text("Make Every Day Count")
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(DF.ink)

                        Text("DayFlow • Version 1.0.0")
                            .font(.system(size: 11))
                            .foregroundStyle(DF.muted)

                        Text("Your daily companion, designed to work offline.")
                            .font(.system(size: 11))
                            .foregroundStyle(DF.muted)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
            .padding(19)
            .padding(.top, 15)
        }
        .confirmationDialog(
            "Delete all reminders?",
            isPresented: $showReset,
            titleVisibility: .visible
        ) {
            Button("Delete All", role: .destructive) {
                store.tasks.forEach { DFNotifications.cancel($0.id) }
                store.tasks.removeAll()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
    }

    private func profileStat(
        _ title: String,
        _ value: String,
        _ icon: String,
        _ color: Color
    ) -> some View {
        HStack(spacing: 11) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 23, weight: .black))
                    .foregroundStyle(DF.ink)

                Text(title)
                    .font(.system(size: 10))
                    .foregroundStyle(DF.muted)
            }

            Spacer(minLength: 0)
        }
        .padding(15)
        .background(DF.paper)
        .clipShape(RoundedRectangle(cornerRadius: 17))
    }

    private func profileRow(_ title: String, _ icon: String, _ color: Color) -> some View {
        HStack(spacing: 13) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 22)

            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(DF.ink)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(DF.muted)
        }
        .padding(16)
        .contentShape(Rectangle())
    }
}
