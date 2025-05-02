import Foundation

struct Habit: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let isDurationBased: Bool
    var completedSessions: [PomodoroSession]
    var streak: Int = 0
    var totalFocusTime: TimeInterval {
        completedSessions.reduce(0) { $0 + TimeInterval($1.focusMinutes * 60) }
    }
    
    init(id: UUID = UUID(), name: String, isDurationBased: Bool, completedSessions: [PomodoroSession] = [], streak: Int = 0) {
        self.id = id
        self.name = name
        self.isDurationBased = isDurationBased
        self.completedSessions = completedSessions
        self.streak = streak
    }
}

struct HabitLog: Identifiable, Codable, Hashable {
    let id: UUID
    let habitId: UUID
    let date: Date
    let duration: Int?
    let count: Int?
    
    init(id: UUID = UUID(), habitId: UUID, date: Date, duration: Int? = nil, count: Int? = nil) {
        self.id = id
        self.habitId = habitId
        self.date = date
        self.duration = duration
        self.count = count
    }
} 