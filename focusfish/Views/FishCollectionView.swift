import SwiftUI

struct FishCollectionView: View {
    @ObservedObject var habitViewModel: HabitViewModel
    @State private var selectedRarity: FishRarity?
    
    private let columns = [
        GridItem(.adaptive(minimum: 80), spacing: 10)
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Top title
            Text("Fish Collection")
                .font(.custom("Menlo", size: 24))
                .bold()
                .foregroundColor(.black)
                .padding(.top, 20)
            
            // Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    rarityFilterButton(title: "All", rarity: nil)
                    
                    ForEach(FishRarity.allCases) { rarity in
                        rarityFilterButton(title: rarityDisplayName(rarity), rarity: rarity)
                    }
                }
                .padding(.horizontal)
            }
            
            // Statistics
            fishStatsView
                .padding(.horizontal)
            
            // Fish grid
            if filteredFish.isEmpty {
                VStack(spacing: 10) {
                    Spacer()
                    
                    Text("No fish collected yet")
                        .font(.custom("Menlo", size: 18))
                        .foregroundColor(.black)
                    
                    Text("Complete focus sessions to earn fish rewards")
                        .font(.custom("Menlo", size: 14))
                        .foregroundColor(.gray)
                    
                    // Add demo fish button
                    PixelButton(
                        text: "Add Demo Fish",
                        action: {
                            Task {
                                await addDemoFish()
                            }
                        }
                    )
                    .buttonStyle(PixelButtonStyle())
                    .padding()
                    
                    Spacer()
                }
                .padding()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filteredFish) { fish in
                            fishCell(fish: fish)
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            // Add demo fish on first launch if collection is empty
            if habitViewModel.getAllFish().isEmpty {
                Task {
                    await addDemoFish()
                }
            }
        }
    }
    
    // Add demo fish for testing
    private func addDemoFish() async {
        // Add a variety of fish with different rarities
        for _ in 1...5 {
            await addRandomFish(rarity: .common)
        }
        
        for _ in 1...3 {
            await addRandomFish(rarity: .rare)
        }
        
        for _ in 1...2 {
            await addRandomFish(rarity: .epic)
        }
    }
    
    private func addRandomFish(rarity: FishRarity) async {
        let focusMinutes = Int.random(in: 15...60)
        let fish = Fish(rarity: rarity, focusMinutes: focusMinutes)
        
        // Create a random past date within the last 90 days
        let daysAgo = Int.random(in: 1...90)
        let pastDate = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        
        // Create a session with this fish
        let session = PomodoroSession(
            startTime: pastDate,
            focusMinutes: focusMinutes,
            fish: fish
        )
        
        // If there's at least one habit, add it to the first habit
        if let firstHabit = habitViewModel.habits.first {
            await habitViewModel.addSession(to: firstHabit, session: session)
        } else {
            // Create a habit if none exists
            let habit = await habitViewModel.addHabit("Fish Collection")
            await habitViewModel.addSession(to: habit, session: session)
        }
    }
    
    private func rarityFilterButton(title: String, rarity: FishRarity?) -> some View {
        Button(action: {
            selectedRarity = rarity
        }) {
            Text(title)
                .font(.custom("Menlo", size: 14))
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.black, lineWidth: 1)
                        .background(selectedRarity == rarity ? Color.black.opacity(0.2) : Color.white)
                )
                .foregroundColor(selectedRarity == rarity ? .black : .black)
        }
    }
    
    private var fishStatsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Collection Stats")
                .font(.custom("Menlo", size: 18))
                .bold()
                .foregroundColor(.black)
            
            let fishStats = habitViewModel.getFishStats()
            let totalFish = fishStats.values.reduce(0, +)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Total: \(totalFish) fish")
                    .font(.custom("Menlo", size: 14))
                    .foregroundColor(.black)
                
                HStack(spacing: 15) {
                    ForEach(FishRarity.allCases) { rarity in
                        HStack(spacing: 5) {
                            Text("\(rarityShortName(rarity)):")
                                .font(.custom("Menlo", size: 12))
                            
                            Text("\(fishStats[rarity, default: 0])")
                                .font(.custom("Menlo", size: 12))
                                .bold()
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black, lineWidth: 1)
            )
        }
    }
    
    private func fishCell(fish: Fish) -> some View {
        VStack(spacing: 5) {
            PixelFishView(rarity: fish.rarity, size: 60, iconName: fish.icon)
            
            Text(formatDate(fish.catchDate))
                .font(.custom("Menlo", size: 10))
                .foregroundColor(.gray)
            
            Text("\(fish.focusMinutes) min")
                .font(.custom("Menlo", size: 10))
                .foregroundColor(.black)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.black, lineWidth: 1)
        )
    }
    
    private var filteredFish: [Fish] {
        let allFish = habitViewModel.getAllFish()
        guard let selectedRarity = selectedRarity else {
            return allFish
        }
        return allFish.filter { $0.rarity == selectedRarity }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
    
    private func rarityDisplayName(_ rarity: FishRarity) -> String {
        rarity.displayName
    }
    
    private func rarityShortName(_ rarity: FishRarity) -> String {
        switch rarity {
        case .common:
            return "C"
        case .rare:
            return "R"
        case .epic:
            return "E"
        }
    }
}

struct FishCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        let habitViewModel = HabitViewModel()
        return FishCollectionView(habitViewModel: habitViewModel)
    }
} 