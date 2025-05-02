import Foundation

final class PomodoroSession: Codable, Hashable {
    let id: UUID
    let startTime: Date
    var endTime: Date?
    let focusMinutes: Int
    let breakMinutes: Int
    var isCompleted: Bool
    var habitId: UUID?
    var fish: Fish?
    
    // Default: 25 minutes focus, 5 minutes break
    init(startTime: Date = Date(), focusMinutes: Int = 25, breakMinutes: Int = 5, habitId: UUID? = nil, fish: Fish? = nil) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = nil
        self.focusMinutes = focusMinutes
        self.breakMinutes = breakMinutes
        self.isCompleted = false
        self.habitId = habitId
        self.fish = fish
    }
    
    func complete() {
        self.endTime = Date()
        self.isCompleted = true
        self.fish = Fish.catchNewFish(focusMinutes: self.focusMinutes)
    }
    
    // Complete with actual focus time (for count-up mode)
    func completeWithActualTime(actualFocusMinutes: Int) {
        self.endTime = Date()
        self.isCompleted = true
        self.fish = Fish.catchNewFish(focusMinutes: actualFocusMinutes)
    }
    
    var duration: TimeInterval {
        guard let endTime = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return endTime.timeIntervalSince(startTime)
    }
    
    // MARK: - Hashable
    static func == (lhs: PomodoroSession, rhs: PomodoroSession) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
} 