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
    @Published var elapsedSeconds: Int = 0 // 正向计时已过秒数
    @Published var progress: Double = 0.0
    @Published var timerMode: TimerMode = .countdown
    
    // Settings
    @Published var selectedHabitId: UUID?
    
    // Current session
    private var currentSession: PomodoroSession?
    private var timer: Timer?
    private var totalSeconds: Int = 25 * 60
    private var currentFish: Fish?
    private var startTime: Date?
    
    // Sound settings
    let soundSettings: SoundSettings
    
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
        timerState = .idle
        
        if timerMode == .countdown {
            // 处理0值为2秒倒计时（用于测试）
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
            // 处理0值为2秒倒计时（用于测试）
            let actualFocusMinutes = focusMinutes == 0 ? 0 : focusMinutes
            currentSession = PomodoroSession(
                startTime: Date(),
                focusMinutes: actualFocusMinutes,
                breakMinutes: breakMinutes,
                habitId: selectedHabitId
            )
        }
        
        timerState = .running
        
        // 确保使用RunLoop.main并使用固定的时间间隔
        timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.updateTimer()
            }
        }
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
        
        // 对于正计时模式，检查是否可以获得鱼
        if timerMode == .countup && timerState == .running {
            await checkCountUpCompletionAndGetFish()
        } else {
            // 对于倒计时模式，直接重置
            await resetTimer()
        }
    }
    
    private func updateTimer() async {
        if timerMode == .countdown {
            updateCountdownTimer()
        } else {
            updateCountUpTimer()
        }
    }
    
    private func updateCountdownTimer() {
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
                
                // 自动开始休息时间
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
        elapsedSeconds += 1
        
        // 计算进度百分比，在Count Up模式下进度只是视觉指示，每小时为一个周期
        let oneHourInSeconds = 60 * 60
        progress = (Double(elapsedSeconds % oneHourInSeconds) / Double(oneHourInSeconds))
    }
    
    // 当计时器停止时检查是否可以获得鱼（仅适用于Count Up模式）
    func checkCountUpCompletionAndGetFish() async {
        // 只有在正计时模式下才执行
        guard timerMode == .countup else { return }
        
        // 停止计时器
        timer?.invalidate()
        timer = nil
        
        // 如果计时超过25分钟，创建一条鱼并设置状态为完成
        if elapsedSeconds >= 25 * 60 {
            currentFish = generateFish(focusMinutes: elapsedSeconds / 60)
            timerState = .finished
            
            // 自动开始休息时间
            Task { await startBreakAfterDelay() }
        } else {
            // 不满足获得鱼的条件，重置为空闲状态
            timerState = .idle
        }
    }
    
    // 当显示鱼类奖励后延迟开始休息时间
    private func startBreakAfterDelay() async {
        // 等待3秒后自动开始休息时间(给用户时间查看获得的鱼)
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        
        // 检查状态是否还是finished，如果用户已经切换了状态则不自动开始休息
        if timerState == .finished {
            await startBreak()
        }
    }
    
    func startBreak() async {
        timerState = .inBreak
        remainingSeconds = breakMinutes * 60
        totalSeconds = remainingSeconds
        progress = 0.0
        
        // 休息状态直接启动计时器，不创建新的会话也不会有新的鱼
        timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.updateTimer()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func generateFish(focusMinutes: Int) -> Fish {
        return Fish(rarity: calculateRarity(focusMinutes: focusMinutes), focusMinutes: focusMinutes)
    }
    
    private func calculateRarity(focusMinutes: Int) -> FishRarity {
        // 根据专注时间决定稀有度，时间越长稀有度越高
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