import Foundation
import Combine
import SwiftUI

@MainActor
class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var selectedHabit: Habit?
    @Published var habitLogs: [Date: [HabitLog]] = [:]
    @Published var sessions: [String: [PomodoroSession]] = [:] // habitId: [sessions]
    
    init() {
        Task {
            await loadData()
        }
    }
    
    private func loadData() async {
        do {
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.loadHabits() }
                group.addTask { await self.loadLogs() }
                group.addTask { await self.loadSessions() }
            }
        }
    }
    
    // MARK: - Habit Management
    func addHabit(_ name: String, isDurationBased: Bool = true) async -> Habit {
        let habit = Habit(name: name, isDurationBased: isDurationBased)
        habits.append(habit)
        await saveHabits()
        return habit
    }
    
    func deleteHabit(_ habit: Habit) async {
        habits.removeAll { $0.id == habit.id }
        await saveHabits()
    }
    
    // MARK: - Session Management
    func addSession(to habit: Habit, session: PomodoroSession) async {
        var habitSessions = sessions[habit.id.uuidString] ?? []
        habitSessions.append(session)
        sessions[habit.id.uuidString] = habitSessions
        
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            var updatedHabit = habit
            updatedHabit.completedSessions.append(session)
            updateStreak(for: &updatedHabit)
            habits[index] = updatedHabit
            await saveHabits()
        }
        
        await saveSessions()
    }
    
    func getAllFish() -> [Fish] {
        var allFish: [Fish] = []
        for habitSessions in sessions.values {
            allFish.append(contentsOf: habitSessions.compactMap { $0.fish })
        }
        return allFish.sorted { $0.catchDate > $1.catchDate }
    }
    
    func getFishStats() -> [FishRarity: Int] {
        var stats: [FishRarity: Int] = [:]
        let allFish = getAllFish()
        
        for fish in allFish {
            stats[fish.rarity, default: 0] += 1
        }
        
        return stats
    }
    
    func getFishGroupedByRarity(for habit: Habit) -> [FishRarity: Int] {
        var stats: [FishRarity: Int] = [:]
        let fish = habit.completedSessions.compactMap { $0.fish }
        
        for fish in fish {
            stats[fish.rarity, default: 0] += 1
        }
        
        return stats
    }
    
    func getTotalFocusTime() -> TimeInterval {
        var totalTime: TimeInterval = 0
        for habit in habits {
            totalTime += habit.totalFocusTime
        }
        return totalTime
    }
    
    func getTotalCompletedSessions() -> Int {
        habits.reduce(0) { $0 + $1.completedSessions.count }
    }
    
    func getLongestStreak() -> Int {
        habits.map { $0.streak }.max() ?? 0
    }
    
    func getHeatmap(for habit: Habit) -> [Date: Int] {
        var heatmap: [Date: Int] = [:]
        let calendar = Calendar.current
        
        for session in habit.completedSessions {
            let date = calendar.startOfDay(for: session.startTime)
            heatmap[date, default: 0] += 1
        }
        
        return heatmap
    }
    
    // MARK: - Log Management
    func logHabit(_ habit: Habit, duration: Int? = nil, count: Int? = nil, date: Date = Date()) async {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        
        let log = HabitLog(
            habitId: habit.id,
            date: normalizedDate,
            duration: duration,
            count: count
        )
        
        var logs = habitLogs[normalizedDate] ?? []
        logs.append(log)
        habitLogs[normalizedDate] = logs
        
        await saveLogs()
    }
    
    func getLogs(for date: Date) -> [HabitLog] {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        return habitLogs[normalizedDate] ?? []
    }
    
    func getTotalDuration(for habit: Habit, on date: Date) -> Int {
        let logs = getLogs(for: date).filter { $0.habitId == habit.id }
        return logs.compactMap { $0.duration }.reduce(0, +)
    }
    
    func getTotalCount(for habit: Habit, on date: Date) -> Int {
        let logs = getLogs(for: date).filter { $0.habitId == habit.id }
        return logs.compactMap { $0.count }.reduce(0, +)
    }
    
    // MARK: - Helper Methods
    private func updateStreak(for habit: inout Habit) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Sort sessions by date
        let sortedSessions = habit.completedSessions.sorted { $0.startTime < $1.startTime }
        
        // Get unique dates
        var dates: Set<Date> = []
        for session in sortedSessions {
            let date = calendar.startOfDay(for: session.startTime)
            dates.insert(date)
        }
        
        // Convert to array and sort
        let sortedDates = Array(dates).sorted()
        
        // Calculate current streak
        var streak = 0
        var currentDate = today
        
        while dates.contains(currentDate) {
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        habit.streak = streak
    }
    
    // MARK: - Persistence
    private func saveHabits() async {
        do {
            let data = try JSONEncoder().encode(habits)
            UserDefaults.standard.set(data, forKey: "habits")
        } catch {
            print("Error saving habits: \(error)")
        }
    }
    
    private func loadHabits() async {
        guard let data = UserDefaults.standard.data(forKey: "habits") else { return }
        do {
            let decodedHabits = try JSONDecoder().decode([Habit].self, from: data)
            habits = decodedHabits
        } catch {
            print("Error loading habits: \(error)")
        }
    }
    
    private func saveLogs() async {
        do {
            let data = try JSONEncoder().encode(habitLogs)
            UserDefaults.standard.set(data, forKey: "habitLogs")
        } catch {
            print("Error saving logs: \(error)")
        }
    }
    
    private func loadLogs() async {
        guard let data = UserDefaults.standard.data(forKey: "habitLogs") else { return }
        do {
            let decodedLogs = try JSONDecoder().decode([Date: [HabitLog]].self, from: data)
            habitLogs = decodedLogs
        } catch {
            print("Error loading logs: \(error)")
        }
    }
    
    private func saveSessions() async {
        do {
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: "habitSessions")
        } catch {
            print("Error saving sessions: \(error)")
        }
    }
    
    private func loadSessions() async {
        guard let data = UserDefaults.standard.data(forKey: "habitSessions") else { return }
        do {
            let decodedSessions = try JSONDecoder().decode([String: [PomodoroSession]].self, from: data)
            sessions = decodedSessions
        } catch {
            print("Error loading sessions: \(error)")
        }
    }
} 