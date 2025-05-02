import SwiftUI

struct FishCaughtView: View {
    let fish: Fish
    @ObservedObject var habitViewModel: HabitViewModel
    @ObservedObject var petViewModel: PetViewModel
    @Binding var isShowing: Bool
    @State private var selectedHabit: Habit?
    
    var onAddToCollection: (Habit, Fish) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Title with fish name
            Text("You caught \(fish.icon.capitalized)!")
                .font(.custom("Menlo", size: 24))
                .bold()
                .foregroundColor(.black)
                .padding(.top, 40)
                .multilineTextAlignment(.center)
            
            // Fish image
            PixelFishView(rarity: fish.rarity, size: 120, iconName: fish.icon)
                .padding(.vertical, 20)
            
            // Rarity text
            Text(fish.rarity.displayName)
                .font(.custom("Menlo", size: 18))
                .bold()
                .foregroundColor(.black)
            
            // Habit picker
            if !habitViewModel.habits.isEmpty {
                Picker("Select Habit", selection: $selectedHabit) {
                    Text("Select Habit").tag(nil as Habit?)
                    ForEach(habitViewModel.habits) { habit in
                        Text(habit.name).tag(habit as Habit?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .onAppear {
                    if selectedHabit == nil {
                        selectedHabit = habitViewModel.habits.first
                    }
                }
            }
            
            // Button area
            VStack(spacing: 15) {
                // Collection button
                PixelButton(
                    text: "Add to Collection",
                    action: {
                        if let habit = selectedHabit {
                            onAddToCollection(habit, fish)
                            // Also add to pet's collection
                            petViewModel.addFishToCollection(fish)
                            isShowing = false
                        }
                    }
                )
                .buttonStyle(PixelButtonStyle(backgroundColor: .gray, textColor: .white))
                .disabled(selectedHabit == nil)
                
                // Feed button
                PixelButton(
                    text: "Feed to Pet",
                    action: {
                        petViewModel.feedFish(fish)
                        isShowing = false
                    }
                )
                .buttonStyle(PixelButtonStyle(backgroundColor: .gray, textColor: .white))
            }
            .padding(.vertical, 20)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}

struct FishCaughtView_Previews: PreviewProvider {
    static var previews: some View {
        FishCaughtView(
            fish: Fish(rarity: .epic, focusMinutes: 25),
            habitViewModel: HabitViewModel(),
            petViewModel: PetViewModel(),
            isShowing: .constant(true),
            onAddToCollection: { _, _ in }
        )
    }
} 