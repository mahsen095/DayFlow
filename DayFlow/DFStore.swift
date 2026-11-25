import Foundation

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
