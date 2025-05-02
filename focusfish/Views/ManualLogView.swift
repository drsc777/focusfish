import SwiftUI

struct ManualLogView: View {
    @ObservedObject var habitViewModel: HabitViewModel
    @Binding var isPresented: Bool
    @State private var selectedHabit: Habit?
    @State private var selectedDate = Date()
    @State private var duration: String = ""
    @State private var count: String = ""
    @State private var isDurationBased: Bool = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Habit")) {
                    Picker("Habit", selection: $selectedHabit) {
                        Text("Please Select").tag(nil as Habit?)
                        ForEach(habitViewModel.habits) { habit in
                            Text(habit.name).tag(habit as Habit?)
                        }
                    }
                }
                
                Section(header: Text("Select Date")) {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
                
                Section(header: Text("Record Type")) {
                    Picker("Record Type", selection: $isDurationBased) {
                        Text("Duration").tag(true)
                        Text("Count").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                if isDurationBased {
                    Section(header: Text("Focus Duration (minutes)")) {
                        TextField("Enter duration", text: $duration)
                            #if os(iOS)
                            .keyboardType(.numberPad)
                            #endif
                    }
                } else {
                    Section(header: Text("Completion Count")) {
                        TextField("Enter count", text: $count)
                            #if os(iOS)
                            .keyboardType(.numberPad)
                            #endif
                    }
                }
            }
            .navigationTitle("Manual Log")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                    isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                    Task {
                        await saveLog()
                        }
                    }
                }
            }
        }
    }
    
    private func saveLog() async {
        guard let selectedHabit = selectedHabit else { return }
        
        if isDurationBased {
            if let minutes = Int(duration) {
                await habitViewModel.logHabit(selectedHabit, duration: minutes, date: selectedDate)
            }
        } else {
            if let times = Int(count) {
                await habitViewModel.logHabit(selectedHabit, count: times, date: selectedDate)
            }
        }
        
        isPresented = false
    }
} 