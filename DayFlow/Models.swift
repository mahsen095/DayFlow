import SwiftUI

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
