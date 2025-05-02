import SwiftUI

struct HabitView: View {
    @ObservedObject var habitViewModel: HabitViewModel
    @State private var showAddHabit = false
    @State private var newHabitName = ""
    @State private var selectedHabit: Habit?
    
    let calendar = Calendar.current
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Top title
                Text("Habit Tracking")
                    .font(.custom("Menlo", size: 24))
                    .bold()
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                if habitViewModel.habits.isEmpty {
                    // Prompt when no habits exist
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Text("No Habits Yet")
                            .font(.custom("Menlo", size: 18))
                            .foregroundColor(.black)
                        
                        Text("Click the button below to add your first habit")
                            .font(.custom("Menlo", size: 14))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                        
                        PixelButton(
                            text: "Add Habit",
                            action: { 
                                showAddHabit = true 
                            }
                        )
                        .buttonStyle(PixelButtonStyle())
                        
                        Spacer()
                    }
                    .padding()
                } else {
                    // Show habits list and statistics
                    ScrollView {
                        VStack(spacing: 30) {
                            // Statistics overview
                            statisticsView
                                .padding(.horizontal)
                                .padding(.top)
                            
                            // Habit list with individual heatmaps
                            VStack(alignment: .leading, spacing: 10) {
                                Text("My Habits")
                                    .font(.custom("Menlo", size: 18))
                                    .bold()
                                    .foregroundColor(.black)
                                
                                ForEach(habitViewModel.habits) { habit in
                                    habitCardWithHeatmap(habit: habit)
                                        .onTapGesture {
                                            selectedHabit = habit
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 80)
                    }
                }
            }
            
            // Floating add button
            if !habitViewModel.habits.isEmpty {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            showAddHabit = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    Circle()
                                        .fill(Color.black)
                                )
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddHabit) {
            addHabitView
        }
        .sheet(item: $selectedHabit) { habit in
            habitDetailView(habit: habit)
        }
    }
    
    // Individual habit card with heatmap
    private func habitCardWithHeatmap(habit: Habit) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            // Habit info
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(habit.name)
                        .font(.custom("Menlo", size: 16))
                        .bold()
                        .foregroundColor(.black)
                    
                    HStack(spacing: 15) {
                        Text("Count: \(habit.completedSessions.count)")
                            .font(.custom("Menlo", size: 12))
                        
                        Text("Streak: \(habit.streak) days")
                            .font(.custom("Menlo", size: 12))
                    }
                    .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.black)
            }
            
            // Habit-specific heatmap
            HeatmapView(
                data: habitViewModel.getHeatmap(for: habit),
                cellSize: 10,
                spacing: 4,
                showMonthLabels: false
            )
            .frame(height: 120)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black, lineWidth: 1)
        )
    }
    
    private var statisticsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Overall Statistics")
                .font(.custom("Menlo", size: 18))
                .bold()
                .foregroundColor(.black)
            
            HStack(spacing: 20) {
                statCard(
                    title: "Total Focus",
                    value: formatTimeInterval(habitViewModel.getTotalFocusTime())
                )
                
                statCard(
                    title: "Total Count",
                    value: "\(habitViewModel.getTotalCompletedSessions())"
                )
                
                statCard(
                    title: "Longest Streak",
                    value: "\(habitViewModel.getLongestStreak()) days"
                )
            }
        }
    }
    
    private func statCard(title: String, value: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.custom("Menlo", size: 12))
                .foregroundColor(.gray)
            
            Text(value)
                .font(.custom("Menlo", size: 16))
                .bold()
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.black, lineWidth: 1)
        )
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m"
    }
    
    private var addHabitView: some View {
        NavigationView {
            Form {
                Section(header: Text("Habit Name")) {
                    TextField("Enter habit name", text: $newHabitName)
                }
            }
            .navigationTitle("Add New Habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                    showAddHabit = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                    Task {
                        if !newHabitName.isEmpty {
                            await habitViewModel.addHabit(newHabitName)
                            newHabitName = ""
                            showAddHabit = false
                        }
                    }
                }
                .disabled(newHabitName.isEmpty)
                }
            }
        }
    }
    
    private func habitDetailView(habit: Habit) -> some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Detailed statistics
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Statistics")
                            .font(.custom("Menlo", size: 18))
                            .bold()
                            .foregroundColor(.black)
                        
                        HStack(spacing: 20) {
                            statCard(
                                title: "Focus Time",
                                value: formatTimeInterval(habit.totalFocusTime)
                            )
                            
                            statCard(
                                title: "Sessions",
                                value: "\(habit.completedSessions.count)"
                            )
                            
                            statCard(
                                title: "Streak",
                                value: "\(habit.streak) days"
                            )
                        }
                    }
                    .padding()
                    
                    // Fish collection for this habit
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Fish Collection")
                            .font(.custom("Menlo", size: 18))
                            .bold()
                            .foregroundColor(.black)
                        
                        let fishStats = habitViewModel.getFishGroupedByRarity(for: habit)
                        
                        HStack(spacing: 15) {
                            ForEach(FishRarity.allCases) { rarity in
                                VStack(spacing: 5) {
                                    Text(rarity.displayName)
                                        .font(.custom("Menlo", size: 12))
                                        .foregroundColor(.gray)
                                    
                                    Text("\(fishStats[rarity, default: 0])")
                                        .font(.custom("Menlo", size: 16))
                                        .bold()
                                        .foregroundColor(.black)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 1)
                        )
                    }
                    .padding()
                    
                    // Full year heatmap
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Activity Heatmap")
                            .font(.custom("Menlo", size: 18))
                            .bold()
                            .foregroundColor(.black)
                        
                        HeatmapView(
                            data: habitViewModel.getHeatmap(for: habit),
                            cellSize: 12,
                            spacing: 4,
                            showMonthLabels: true
                        )
                        .frame(height: 220)
                    }
                    .padding()
                    
                    // Delete habit button
                    Button(action: {
                        Task {
                            await habitViewModel.deleteHabit(habit)
                            selectedHabit = nil
                        }
                    }) {
                        Text("Delete Habit")
                            .font(.custom("Menlo", size: 14))
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color.gray)
                            .cornerRadius(4)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle(habit.name)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                    selectedHabit = nil
                    }
                }
            }
        }
    }
}

struct HabitView_Previews: PreviewProvider {
    static var previews: some View {
        let habitViewModel = HabitViewModel()
        return HabitView(habitViewModel: habitViewModel)
    }
} 