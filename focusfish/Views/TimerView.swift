import SwiftUI

struct TimerView: View {
    @ObservedObject var timerViewModel: TimerViewModel
    @ObservedObject var habitViewModel: HabitViewModel
    @ObservedObject var petViewModel: PetViewModel
    @ObservedObject var soundSettings: SoundSettings
    
    @State private var showSettings = false
    @State private var showHabitPicker = false
    @State private var showRewardPopup = false
    @State private var showCountUpHabitSelection = false
    @State private var countUpElapsedSeconds: Int = 0
    @State private var showSessionAddedNotification = false
    @State private var sessionAddedHabitName = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main content
                adaptiveLayout(geometry: geometry)
                
                // Overlays
                if showSettings {
                    settingsView
                }
                
                if showHabitPicker {
                    habitPickerView
                }
                
                if showRewardPopup, let fish = timerViewModel.getCurrentFish() {
                    FishCaughtView(
                        fish: fish,
                        habitViewModel: habitViewModel,
                        petViewModel: petViewModel,
                        isShowing: $showRewardPopup,
                        onAddToCollection: { habit, fish in
                            Task {
                                // Create completed session with proper start and end times
                                let session = PomodoroSession(
                                    startTime: timerViewModel.startTime ?? Date().addingTimeInterval(-TimeInterval(timerViewModel.focusMinutes * 60)),
                                    focusMinutes: timerViewModel.focusMinutes,
                                    habitId: habit.id,
                                    fish: fish
                                )
                                // Mark session as completed with end time
                                session.isCompleted = true
                                session.endTime = Date()
                                
                                await habitViewModel.addSession(to: habit, session: session)
                            }
                        }
                    )
                }
                
                if showCountUpHabitSelection {
                    countUpHabitSelectionView
                }
                
                if showSessionAddedNotification {
                    sessionAddedNotificationView
                }
            }
            .onChange(of: timerViewModel.timerState) { state in
                if state == .finished {
                    showRewardPopup = true
                }
            }
        }
    }
    
    @ViewBuilder
    private func adaptiveLayout(geometry: GeometryProxy) -> some View {
        let isLandscape = geometry.size.width > geometry.size.height
        
        if isLandscape {
            // Landscape layout
            HStack(spacing: 20) {
                // Left side - controls and timer
                VStack(spacing: 20) {
                    // Header with settings button
                    headerView
                    
                    // Timer display
                    timerDisplayView
                    
                    // Control buttons and sound toggle
                    controlsView
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .frame(width: geometry.size.width * 0.4)
                
                // Right side - fishing scene or app logo based on timer state
                if timerViewModel.timerState == .idle {
                    // Show app logo when not started
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: geometry.size.height * 0.8)
                        .padding(.trailing, 20)
                } else {
                    // Show fishing scene when timer is running or paused
                    Image("focus")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: geometry.size.height * 0.8)
                        .padding(.trailing, 20)
                }
            }
        } else {
            // Portrait layout
            VStack(spacing: 20) {
                // Header with settings button
                headerView
                    .padding(.horizontal, 20)
                
                // Timer display
                timerDisplayView
                    .padding(.horizontal, 40)
                
                // Fishing scene or app logo based on timer state
                if timerViewModel.timerState == .idle {
                    // Show app logo when not started
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: .infinity)
                        .padding(.horizontal)
                } else {
                    // Show fishing scene when timer is running or paused
                    Image("focus")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: .infinity)
                        .padding(.horizontal)
                }
                
                // Control buttons and sound toggle
                controlsView
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                
                Spacer()
            }
        }
    }
    
    // Header with settings button
    private var headerView: some View {
        HStack {
            // Settings button
            Button(action: {
                showSettings = true
            }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                    .padding(8)
            }
            
            Spacer()
            
            Text("Focus Fishing")
                .font(.custom("Menlo", size: 24))
                .bold()
                .foregroundColor(.black)
            
            Spacer()
            
            // Sound toggle button (styled like the settings button)
            Button(action: {
                Task {
                    soundSettings.isSoundEnabled.toggle()
                    if soundSettings.isSoundEnabled {
                        await soundSettings.playSound()
                    } else {
                        await soundSettings.stopSound()
                    }
                }
            }) {
                Image(systemName: soundSettings.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                    .padding(8)
            }
        }
        .padding(.horizontal)
    }
    
    // Timer display
    private var timerDisplayView: some View {
        ZStack {
            Rectangle()
                .fill(Color.black)
                .frame(height: 60)
                .cornerRadius(4)
            
            VStack(spacing: 5) {
                Text(timerViewModel.formattedTime())
                    .font(.custom("Menlo", size: 30))
                    .foregroundColor(.white)
                    .bold()
                
                HStack(spacing: 10) {
                    // Status indicator
                    Text(getTimerStateText())
                        .font(.custom("Menlo", size: 12))
                        .foregroundColor(.white.opacity(0.8))
                    
                    ProgressBarView(progress: timerViewModel.progress, height: 6, backgroundColor: .white.opacity(0.3), foregroundColor: .white)
                        .frame(width: 150)
                }
            }
        }
    }
    
    // Get current timer state text
    private func getTimerStateText() -> String {
        switch timerViewModel.timerState {
        case .idle:
            return "Ready"
        case .running:
            return "Focus"
        case .paused:
            return "Paused"
        case .inBreak:
            return "Break"
        case .finished:
            return "Completed"
        }
    }
    
    // Control buttons and sound toggle
    private var controlsView: some View {
        VStack {
            // Control buttons centered
            HStack(spacing: 30) {
                PixelButton(
                    text: "Stop",
                    action: {
                        Task {
                            if timerViewModel.timerMode == .countup && timerViewModel.timerState == .running {
                                countUpElapsedSeconds = timerViewModel.elapsedSeconds
                                await timerViewModel.pauseTimer()
                                showCountUpHabitSelection = true
                            } else {
                                await timerViewModel.stopTimer()
                            }
                        }
                    }
                )
                .buttonStyle(PixelButtonStyle(backgroundColor: .gray, textColor: .white))
                
                PixelButton(
                    text: timerViewModel.timerState == .running ? "Pause" : "Start",
                    action: {
                        Task {
                            if timerViewModel.timerState == .running {
                                await timerViewModel.pauseTimer()
                            } else {
                                await timerViewModel.startTimer()
                            }
                        }
                    }
                )
                .buttonStyle(PixelButtonStyle(backgroundColor: .gray, textColor: .white))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 10)
        }
    }
    
    // Settings view
    private var settingsView: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showSettings = false
                }
            
            // Settings content
            ScrollView {
                VStack(spacing: 20) {
                    Text("Settings")
                        .font(.custom("Menlo", size: 24))
                        .bold()
                        .foregroundColor(.black)
                        .padding(.top, 20)
                    
                    // Timer Mode Selection
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Timer Mode")
                            .font(.custom("Menlo", size: 16))
                            .foregroundColor(.black)
                        
                        HStack(spacing: 15) {
                            ForEach(TimerMode.allCases) { mode in
                                Button(action: {
                                    Task {
                                        timerViewModel.timerMode = mode
                                        await timerViewModel.saveSettings()
                                        await timerViewModel.resetTimer()
                                    }
                                }) {
                                    Text(mode.rawValue)
                                        .font(.custom("Menlo", size: 14))
                                        .foregroundColor(timerViewModel.timerMode == mode ? .white : .black)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(
                                            timerViewModel.timerMode == mode ?
                                                Color.black :
                                                Color.white
                                        )
                                        .cornerRadius(4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(Color.black, lineWidth: 1)
                                        )
                                }
                            }
                        }
                        
                        if timerViewModel.timerMode == .countup {
                            Text("Note: In Count Up mode, you need to focus for at least 25 minutes to catch a fish.")
                                .font(.custom("Menlo", size: 12))
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 2)
                    )
                    
                    // Focus time settings (display time selection for countdown mode)
                    if timerViewModel.timerMode == .countdown {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Focus Time")
                                .font(.custom("Menlo", size: 16))
                                .foregroundColor(.black)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach([0, 5, 10, 15, 25, 30, 45, 60], id: \.self) { minutes in
                                        Button(action: {
                                            Task {
                                                timerViewModel.focusMinutes = minutes
                                                await timerViewModel.saveSettings()
                                                await timerViewModel.resetTimer()
                                            }
                                        }) {
                                            Text(minutes == 0 ? "2s" : "\(minutes)m")
                                                .font(.custom("Menlo", size: 14))
                                                .foregroundColor(timerViewModel.focusMinutes == minutes ? .white : .black)
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 12)
                                                .background(
                                                    timerViewModel.focusMinutes == minutes ?
                                                        Color.black :
                                                        Color.white
                                                )
                                                .cornerRadius(4)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .stroke(Color.black, lineWidth: 1)
                                                )
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 2)
                        )
                    }
                    
                    // Break time settings
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Break Time")
                            .font(.custom("Menlo", size: 16))
                            .foregroundColor(.black)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach([1, 5, 10, 15, 20], id: \.self) { minutes in
                                    Button(action: {
                                        Task {
                                            timerViewModel.breakMinutes = minutes
                                            await timerViewModel.saveSettings()
                                        }
                                    }) {
                                        Text("\(minutes)m")
                                            .font(.custom("Menlo", size: 14))
                                            .foregroundColor(timerViewModel.breakMinutes == minutes ? .white : .black)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 12)
                                            .background(
                                                timerViewModel.breakMinutes == minutes ?
                                                    Color.black :
                                                    Color.white
                                            )
                                            .cornerRadius(4)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 4)
                                                    .stroke(Color.black, lineWidth: 1)
                                            )
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 2)
                    )
                    
                    // Sound settings
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Background Sound")
                            .font(.custom("Menlo", size: 16))
                            .foregroundColor(.black)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(WhiteNoiseType.allCases) { noiseType in
                                    Button(action: {
                                        Task {
                                            soundSettings.whiteNoiseType = noiseType
                                            if soundSettings.isSoundEnabled {
                                                await soundSettings.playSound()
                                            }
                                        }
                                    }) {
                                        Text(noiseType.displayName)
                                            .font(.custom("Menlo", size: 14))
                                            .foregroundColor(soundSettings.whiteNoiseType == noiseType ? .white : .black)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 12)
                                            .background(
                                                soundSettings.whiteNoiseType == noiseType ?
                                                    Color.black :
                                                    Color.white
                                            )
                                            .cornerRadius(4)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 4)
                                                    .stroke(Color.black, lineWidth: 1)
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Volume slider
                        if soundSettings.isSoundEnabled {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Volume")
                                    .font(.custom("Menlo", size: 14))
                                    .foregroundColor(.black)
                                
                                Slider(value: $soundSettings.volume, in: 0...1, step: 0.1)
                                    .accentColor(.black)
                            }
                            .padding(.top, 10)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 2)
                    )
                    
                    PixelButton(
                        text: "Close",
                        action: {
                            showSettings = false
                        }
                    )
                    .buttonStyle(PixelButtonStyle(backgroundColor: .gray, textColor: .white))
                    .padding(.vertical, 20)
                }
                .padding(.horizontal, 20)
            }
            .background(Color.white)
            .cornerRadius(8)
            .padding(.vertical, 40)
            .padding(.horizontal, 20)
        }
    }
    
    // Habit picker view
    private var habitPickerView: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showHabitPicker = false
                }
            
            // Habit selection content
            VStack(spacing: 20) {
                Text("Select Habit")
                    .font(.custom("Menlo", size: 24))
                    .bold()
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                if habitViewModel.habits.isEmpty {
                    Text("No habits yet")
                        .font(.custom("Menlo", size: 16))
                        .foregroundColor(.gray)
                        .padding()
                    
                    PixelButton(
                        text: "Add Habit",
                        action: {
                            // Add a test habit
                            Task {
                                await habitViewModel.addHabit("Test Habit")
                            }
                        }
                    )
                    .buttonStyle(PixelButtonStyle(backgroundColor: .gray, textColor: .white))
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(habitViewModel.habits) { habit in
                                Button(action: {
                                    Task {
                                        timerViewModel.selectedHabitId = habit.id
                                        await timerViewModel.saveSettings()
                                        showHabitPicker = false
                                    }
                                }) {
                                    HStack {
                                        Text(habit.name)
                                            .font(.custom("Menlo", size: 16))
                                            .foregroundColor(.black)
                                        
                                        Spacer()
                                        
                                        if timerViewModel.selectedHabitId == habit.id {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.black)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 300)
                }
                
                PixelButton(
                    text: "Close",
                    action: {
                        showHabitPicker = false
                    }
                )
                .buttonStyle(PixelButtonStyle(backgroundColor: .gray, textColor: .white))
                .padding(.vertical, 20)
            }
            .background(Color.white)
            .cornerRadius(8)
            .padding(.horizontal, 20)
        }
    }
    
    // Count Up habit selection view
    private var countUpHabitSelectionView: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showCountUpHabitSelection = false
                }
            
            // Count Up habit selection content
            VStack(spacing: 20) {
                Text("Add Count Up Session")
                    .font(.custom("Menlo", size: 24))
                    .bold()
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                // Session time info
                VStack(spacing: 5) {
                    Text("Time: \(formatTimeInterval(TimeInterval(countUpElapsedSeconds)))")
                        .font(.custom("Menlo", size: 16))
                        .foregroundColor(.black)
                    
                    if countUpElapsedSeconds >= 25 * 60 {
                        Text("✅ Fish caught!")
                            .font(.custom("Menlo", size: 14))
                            .foregroundColor(.green)
                    } else {
                        VStack(spacing: 3) {
                            Text("⚠️ Less than 25 min (no fish)")
                                .font(.custom("Menlo", size: 14))
                                .foregroundColor(.orange)
                            
                            Text("Session will still be recorded")
                                .font(.custom("Menlo", size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 1)
                )
                
                Text("Short focus sessions are valuable too!")
                    .font(.custom("Menlo", size: 14))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                if habitViewModel.habits.isEmpty {
                    Text("No habits yet")
                        .font(.custom("Menlo", size: 16))
                        .foregroundColor(.gray)
                        .padding()
                    
                    PixelButton(
                        text: "Create Habit",
                        action: {
                            Task {
                                let habit = await habitViewModel.addHabit("New Habit")
                                await saveCountUpSession(to: habit)
                            }
                        }
                    )
                    .buttonStyle(PixelButtonStyle(backgroundColor: .black, textColor: .white))
                } else {
                    Text("Select a habit:")
                        .font(.custom("Menlo", size: 16))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(habitViewModel.habits) { habit in
                                Button(action: {
                                    Task {
                                        await saveCountUpSession(to: habit)
                                    }
                                }) {
                                    HStack {
                                        Text(habit.name)
                                            .font(.custom("Menlo", size: 16))
                                            .foregroundColor(.black)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 300)
                }
                
                HStack(spacing: 15) {
                    // Cancel button
                    PixelButton(
                        text: "Cancel",
                        action: {
                            // Just close dialog and reset
                            Task {
                                await timerViewModel.resetTimer()
                                showCountUpHabitSelection = false
                            }
                        }
                    )
                    .buttonStyle(PixelButtonStyle(backgroundColor: .gray, textColor: .white))
                    
                    // Discard button
                    PixelButton(
                        text: "Discard Session",
                        action: {
                            Task {
                                await timerViewModel.resetTimer()
                                showCountUpHabitSelection = false
                            }
                        }
                    )
                    .buttonStyle(PixelButtonStyle(backgroundColor: .red, textColor: .white))
                }
                .padding(.vertical, 20)
            }
            .background(Color.white)
            .cornerRadius(8)
            .padding(.horizontal, 20)
        }
    }
    
    // Save count up session to a habit
    private func saveCountUpSession(to habit: Habit) async {
        // Ensure even very short sessions are recorded as at least 1 minute
        let actualFocusMinutes = max(1, countUpElapsedSeconds / 60)
        
        // Create a session
        let session = PomodoroSession(
            startTime: timerViewModel.startTime ?? Date().addingTimeInterval(-TimeInterval(countUpElapsedSeconds)),
            focusMinutes: actualFocusMinutes,
            breakMinutes: timerViewModel.breakMinutes,
            habitId: habit.id
        )
        
        // Mark as completed
        session.isCompleted = true
        session.endTime = Date()
        
        // If eligible for fish (25+ minutes), add fish
        if countUpElapsedSeconds >= 25 * 60 {
            session.fish = Fish.catchNewFish(focusMinutes: actualFocusMinutes)
        }
        
        // Save the session to the habit
        await habitViewModel.addSession(to: habit, session: session)
        
        // Reset timer and close dialog
        await timerViewModel.resetTimer()
        showCountUpHabitSelection = false
        
        // Show session added notification
        sessionAddedHabitName = habit.name
        showSessionAddedNotification = true
    }
    
    // Session added notification view
    private var sessionAddedNotificationView: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                VStack(spacing: 8) {
                    Text("Session added to")
                        .font(.custom("Menlo", size: 14))
                        .foregroundColor(.white)
                    
                    Text("\"\(sessionAddedHabitName)\"")
                        .font(.custom("Menlo", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.85))
                )
                .padding(.trailing, 20)
                .padding(.bottom, 20)
                
                Spacer()
            }
        }
        .onAppear {
            // Auto-hide after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showSessionAddedNotification = false
            }
        }
    }
    
    // Helper function to format TimeInterval as a readable string
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(interval.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        let soundSettings = SoundSettings()
        let timerViewModel = TimerViewModel(soundSettings: soundSettings)
        let habitViewModel = HabitViewModel()
        let petViewModel = PetViewModel()
        
        TimerView(
            timerViewModel: timerViewModel,
            habitViewModel: habitViewModel,
            petViewModel: petViewModel,
            soundSettings: soundSettings
        )
    }
} 