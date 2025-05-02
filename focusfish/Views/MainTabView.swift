import SwiftUI

struct MainTabView: View {
    @StateObject private var soundSettings = SoundSettings()
    @StateObject private var timerViewModel: TimerViewModel
    @StateObject private var habitViewModel = HabitViewModel()
    @StateObject private var petViewModel = PetViewModel()
    
    init() {
        let soundSettings = SoundSettings()
        self._soundSettings = StateObject(wrappedValue: soundSettings)
        self._timerViewModel = StateObject(wrappedValue: TimerViewModel(soundSettings: soundSettings))
    }
    
    var body: some View {
        ZStack {
            // White background
            Color.white.edgesIgnoringSafeArea(.all)
            
            TabView {
                TimerView(
                    timerViewModel: timerViewModel,
                    habitViewModel: habitViewModel,
                    petViewModel: petViewModel,
                    soundSettings: soundSettings
                )
                .tabItem {
                    VStack {
                        Image(systemName: "timer")
                            .font(.system(size: 22))
                        Text("Focus")
                            .font(.custom("Menlo", size: 12))
                    }
                }
                
                HabitView(habitViewModel: habitViewModel)
                    .tabItem {
                        VStack {
                            Image(systemName: "chart.bar")
                                .font(.system(size: 22))
                            Text("Habits")
                                .font(.custom("Menlo", size: 12))
                        }
                    }
                
                PetView(petViewModel: petViewModel)
                    .tabItem {
                        VStack {
                            Image(systemName: "pawprint")
                                .font(.system(size: 22))
                            Text("Pet")
                                .font(.custom("Menlo", size: 12))
                        }
                    }
            }
            // Use black as accent color
            .accentColor(.black)
            // Add pixel border
            .overlay(
                Rectangle()
                    .stroke(Color.black, lineWidth: 2)
                    .edgesIgnoringSafeArea(.all)
            )
        }
    }
}

struct SettingsView: View {
    @ObservedObject var soundSettings: SoundSettings
    
    var body: some View {
        VStack(spacing: 20) {
            // Top title
            Text("Settings")
                .font(.custom("Menlo", size: 24))
                .bold()
                .foregroundColor(.black)
                .padding(.top, 20)
            
            // White noise settings
            SoundSettingsView(soundSettings: soundSettings)
                .padding(.horizontal)
            
            Spacer()
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
} 