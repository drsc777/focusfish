import Foundation
import Combine
import SwiftUI
import AVFoundation

enum TimerState {
    case idle
    case running
    case paused
    case inBreak
    case finished
}

enum TimerMode: String, CaseIterable, Identifiable {
    case countdown = "Countdown"
    case countup = "Count Up"
    
    var id: String { self.rawValue }
}

@MainActor
class TimerViewModel: ObservableObject {
    // Timer state
    @Published var timerState: TimerState = .idle
    @Published var focusMinutes: Int = 25
    @Published var breakMinutes: Int = 5
    @Published var remainingSeconds: Int = 25 * 60
    @Published var elapsedSeconds: Int = 0 // Elapsed seconds for count-up timer
    @Published var progress: Double = 0.0
    @Published var timerMode: TimerMode = .countdown
    
    // Settings
    @Published var selectedHabitId: UUID?
    
    // Current session
    private var currentSession: PomodoroSession?
    private var timer: Timer?
    private var totalSeconds: Int = 25 * 60
    private var currentFish: Fish?
    @Published var startTime: Date?
    
    // Sound settings
    let soundSettings: SoundSettings
    
    // Flag to prevent multiple simultaneous timer updates
    private var isUpdating = false
    
    init(soundSettings: SoundSettings) {
        self.soundSettings = soundSettings
        Task {
            await loadSavedSettings()
            await resetTimer()
        }
    }
    
    private func loadSavedSettings() async {
        // Load settings from UserDefaults
        self.focusMinutes = UserDefaults.standard.integer(forKey: "focusMinutes")
        if self.focusMinutes == 0 {
            self.focusMinutes = 25 // Default
        }
        
        self.breakMinutes = UserDefaults.standard.integer(forKey: "breakMinutes")
        if self.breakMinutes == 0 {
            self.breakMinutes = 5 // Default
        }
        
        if let habitIdString = UserDefaults.standard.string(forKey: "selectedHabitId") {
            self.selectedHabitId = UUID(uuidString: habitIdString)
        }
        
        if let modeString = UserDefaults.standard.string(forKey: "timerMode"),
           let mode = TimerMode(rawValue: modeString) {
            self.timerMode = mode
        }
    }
    
    func saveSettings() async {
        await saveSettingsAsync()
    }
    
    private func saveSettingsAsync() async {
        UserDefaults.standard.set(focusMinutes, forKey: "focusMinutes")
        UserDefaults.standard.set(breakMinutes, forKey: "breakMinutes")
        UserDefaults.standard.set(timerMode.rawValue, forKey: "timerMode")
        if let habitId = selectedHabitId {
            UserDefaults.standard.set(habitId.uuidString, forKey: "selectedHabitId")
        } else {
            UserDefaults.standard.removeObject(forKey: "selectedHabitId")
        }
        await resetTimer()
    }
    
    func resetTimer() async {
        // Invalidate any existing timer
        timer?.invalidate()
        timer = nil
        
        timerState = .idle
        
        if timerMode == .countdown {
            // Handle 0 value as 2 second countdown (for testing)
            let actualFocusSeconds = focusMinutes == 0 ? 2 : focusMinutes * 60
            remainingSeconds = actualFocusSeconds
            totalSeconds = remainingSeconds
        } else {
            elapsedSeconds = 0
        }
        progress = 0.0
        
        currentSession = nil
        currentFish = nil
        startTime = nil
    }
    
    func startTimer() async {
        guard timerState != .running else { return }
        
        if timerState == .idle {
            startTime = Date()
            // Handle 0 value as 2 second countdown (for testing)
            let actualFocusMinutes = focusMinutes == 0 ? 0 : focusMinutes
            currentSession = PomodoroSession(
                startTime: Date(),
                focusMinutes: actualFocusMinutes,
                breakMinutes: breakMinutes,
                habitId: selectedHabitId
            )
        }
        
        timerState = .running
        
        // Cancel any existing timer
        timer?.invalidate()
        timer = nil
        
        // Create a more precise timer using scheduledTimer with tolerance set to 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.updateTimer()
            }
        }
        timer?.tolerance = 0 // Set tolerance to 0 for more precise timing
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    func pauseTimer() async {
        timerState = .paused
        timer?.invalidate()
        timer = nil
    }
    
    func stopTimer() async {
        timer?.invalidate()
        timer = nil
        
        // For count-up mode, check if fish can be earned
        if timerMode == .countup {
            // Always check for fish in count-up mode regardless of state
            await checkCountUpCompletionAndGetFish()
        } else {
            // For countdown mode, just reset
            await resetTimer()
        }
    }
    
    private func updateTimer() async {
        // Prevent multiple simultaneous updates
        if isUpdating {
            return
        }
        
        isUpdating = true
        defer { isUpdating = false }
        
        if timerMode == .countdown {
            updateCountdownTimer()
        } else {
            updateCountUpTimer()
        }
    }
    
    private func updateCountdownTimer() {
        print("Updating countdown timer: \(remainingSeconds) seconds remaining")
        
        guard remainingSeconds > 0 else {
            timer?.invalidate()
            timer = nil
            
            if timerState == .running {
                currentSession?.complete()
                currentFish = currentSession?.fish
                timerState = .finished
                if soundSettings.isSoundEnabled {
                    Task { await soundSettings.playSound() }
                }
                
                // Automatically start break time
                Task { await startBreakAfterDelay() }
            } else if timerState == .inBreak {
                timerState = .idle
                if soundSettings.isSoundEnabled {
                    Task { await soundSettings.playSound() }
                }
            }
            return
        }
        
        remainingSeconds -= 1
        progress = 1.0 - Double(remainingSeconds) / Double(totalSeconds)
    }
    
    private func updateCountUpTimer() {
        print("Updating count-up timer: \(elapsedSeconds) seconds elapsed")
        
        elapsedSeconds += 1
        
        // Calculate progress percentage, in Count Up mode progress is just a visual indicator, one cycle per hour
        let oneHourInSeconds = 60 * 60
        progress = (Double(elapsedSeconds % oneHourInSeconds) / Double(oneHourInSeconds))
    }
    
    // Check if fish can be earned when timer stops (only for Count Up mode)
    func checkCountUpCompletionAndGetFish() async {
        // Only execute in count-up mode
        guard timerMode == .countup else { return }
        
        // Stop the timer
        timer?.invalidate()
        timer = nil
        
        // If timer ran for more than 25 minutes, create a fish and set state to finished
        if elapsedSeconds >= 25 * 60 {
            // Calculate actual focus minutes from elapsed seconds
            let actualFocusMinutes = elapsedSeconds / 60
            
            // Update the session with actual focus time
            if let session = currentSession {
                session.completeWithActualTime(actualFocusMinutes: actualFocusMinutes)
                currentFish = session.fish
            } else {
                // Fallback if no session exists
                currentFish = generateFish(focusMinutes: actualFocusMinutes)
            }
            
            timerState = .finished
            
            // Automatically start break time
            Task { await startBreakAfterDelay() }
        } else {
            // Did not meet criteria for earning a fish, reset to idle state
            timerState = .idle
            // Reset other values too
            currentSession = nil
            currentFish = nil
            elapsedSeconds = 0
            progress = 0.0
        }
    }
    
    // Start break time with delay after showing fish reward
    private func startBreakAfterDelay() async {
        // Wait 3 seconds before automatically starting break time (gives user time to view fish earned)
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        
        // Check if state is still finished, don't auto-start break if user has changed the state
        if timerState == .finished {
            await startBreak()
        }
    }
    
    func startBreak() async {
        timerState = .inBreak
        remainingSeconds = breakMinutes * 60
        totalSeconds = remainingSeconds
        progress = 0.0
        
        // In break state, start timer directly without creating new session or new fish
        timer?.invalidate()
        timer = nil
        
        // Create a more precise timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.updateTimer()
            }
        }
        timer?.tolerance = 0 // Set tolerance to 0 for more precise timing
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func generateFish(focusMinutes: Int) -> Fish {
        return Fish(rarity: calculateRarity(focusMinutes: focusMinutes), focusMinutes: focusMinutes)
    }
    
    private func calculateRarity(focusMinutes: Int) -> FishRarity {
        // Determine rarity based on focus time, longer time means higher rarity
        if focusMinutes >= 45 {
            return .epic
        } else if focusMinutes >= 30 {
            return .rare
        } else {
            return .common
        }
    }
    
    func getCurrentFish() -> Fish? {
        return currentFish
    }
    
    func formattedTime() -> String {
        if timerMode == .countdown {
            let minutes = remainingSeconds / 60
            let seconds = remainingSeconds % 60
            return String(format: "%02d:%02d", minutes, seconds)
        } else {
            let hours = elapsedSeconds / 3600
            let minutes = (elapsedSeconds % 3600) / 60
            let seconds = elapsedSeconds % 60
            
            if hours > 0 {
                return String(format: "%d:%02d:%02d", hours, minutes, seconds)
            } else {
                return String(format: "%02d:%02d", minutes, seconds)
            }
        }
    }
} 