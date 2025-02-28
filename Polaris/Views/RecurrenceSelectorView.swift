//
//  RecurrenceSelectorView.swift
//  Polaris
//
//  Created by Kevin Perez on 2/25/25.
//

import SwiftUI
import SwiftData

struct RecurrenceSelectorView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var todo: Todo
    @State private var isRecurring: Bool
    @State private var selectedPattern: RecurrencePattern
    @State private var endDate: Date?
    @State private var recurrenceCount: Int?
    @State private var hasEndDate: Bool = false
    @State private var hasRecurrenceCount: Bool = false
    @State private var showCustomOptions: Bool = false
    
    // For custom recurrence
    @State private var customRecurrence: CustomRecurrence
    
    init(todo: Todo) {
        self.todo = todo
        
        // Initialize state from todo properties
        _isRecurring = State(initialValue: todo.isRecurring)
        _selectedPattern = State(initialValue: todo.recurrencePatternEnum)
        _endDate = State(initialValue: todo.recurrenceEndDate)
        _recurrenceCount = State(initialValue: todo.recurrenceCount)
        _hasEndDate = State(initialValue: todo.recurrenceEndDate != nil)
        _hasRecurrenceCount = State(initialValue: todo.recurrenceCount != nil)
        
        // Initialize custom recurrence
        if let customData = todo.getCustomRecurrence() {
            _customRecurrence = State(initialValue: customData)
        } else {
            _customRecurrence = State(initialValue: CustomRecurrence())
        }
        
        _showCustomOptions = State(initialValue: todo.recurrencePatternEnum == .custom)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Recurring Task", isOn: $isRecurring)
                        .onChange(of: isRecurring) { _, newValue in
                            if !newValue {
                                // Reset values when turning off recurrence
                                selectedPattern = .none
                                hasEndDate = false
                                hasRecurrenceCount = false
                                endDate = nil
                                recurrenceCount = nil
                            }
                        }
                }
                
                if isRecurring {
                    Section(header: Text("Repeat Pattern")) {
                        Picker("Frequency", selection: $selectedPattern) {
                            ForEach(RecurrencePattern.allCases, id: \.self) { pattern in
                                if pattern != .none {
                                    Text(pattern.rawValue)
                                }
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: selectedPattern) { _, newValue in
                            showCustomOptions = (newValue == .custom)
                        }
                    }
                    
                    if showCustomOptions {
                        Section(header: Text("Custom Recurrence")) {
                            Picker("Repeat Every", selection: $customRecurrence.frequency) {
                                ForEach(1...30, id: \.self) { i in
                                    Text("\(i)")
                                }
                            }
                            
                            Picker("Unit", selection: $customRecurrence.unit) {
                                Text("Day").tag(CustomRecurrence.RecurrenceUnit.day)
                                Text("Week").tag(CustomRecurrence.RecurrenceUnit.week)
                                Text("Month").tag(CustomRecurrence.RecurrenceUnit.month)
                                Text("Year").tag(CustomRecurrence.RecurrenceUnit.year)
                            }
                            
                            if customRecurrence.unit == .week {
                                NavigationLink("Days of Week") {
                                    DaysOfWeekSelector(selectedDays: Binding(
                                        get: { customRecurrence.daysOfWeek ?? [] },
                                        set: { customRecurrence.daysOfWeek = $0 }
                                    ))
                                }
                            }
                            
                            if customRecurrence.unit == .month {
                                Picker("Day of Month", selection: Binding(
                                    get: { customRecurrence.dayOfMonth ?? 1 },
                                    set: { customRecurrence.dayOfMonth = $0 }
                                )) {
                                    ForEach(1...31, id: \.self) { day in
                                        Text("\(day)")
                                    }
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("End Recurrence")) {
                        Toggle("End After Date", isOn: $hasEndDate)
                            .onChange(of: hasEndDate) { _, newValue in
                                if !newValue {
                                    endDate = nil
                                } else if endDate == nil {
                                    // Default to 1 year from today
                                    endDate = Calendar.current.date(byAdding: .year, value: 1, to: Date.now)
                                }
                                
                                // Mutually exclusive with count
                                if newValue && hasRecurrenceCount {
                                    hasRecurrenceCount = false
                                    recurrenceCount = nil
                                }
                            }
                        
                        if hasEndDate {
                            DatePicker("End Date", selection: Binding(
                                get: { endDate ?? Date.now },
                                set: { endDate = $0 }
                            ), displayedComponents: .date)
                        }
                        
                        Toggle("End After Count", isOn: $hasRecurrenceCount)
                            .onChange(of: hasRecurrenceCount) { _, newValue in
                                if !newValue {
                                    recurrenceCount = nil
                                } else if recurrenceCount == nil {
                                    recurrenceCount = 10 // Default
                                }
                                
                                // Mutually exclusive with end date
                                if newValue && hasEndDate {
                                    hasEndDate = false
                                    endDate = nil
                                }
                            }
                        
                        if hasRecurrenceCount {
                            Stepper(value: Binding(
                                get: { recurrenceCount ?? 10 },
                                set: { recurrenceCount = $0 }
                            ), in: 1...100) {
                                Text("Occur \(recurrenceCount ?? 10) times")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Recurrence")
			#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRecurrenceSettings()
                        dismiss()
                    }
                }
            }
			#endif
        }
    }
    
    private func saveRecurrenceSettings() {
        todo.isRecurring = isRecurring
        
        if isRecurring {
            todo.recurrencePatternEnum = selectedPattern
            todo.recurrenceEndDate = hasEndDate ? endDate : nil
            todo.recurrenceCount = hasRecurrenceCount ? recurrenceCount : nil
            
            if selectedPattern == .custom {
                todo.setCustomRecurrence(customRecurrence)
            } else {
                todo.customRecurrenceData = nil
            }
        } else {
            // Reset all recurrence properties
            todo.recurrencePatternEnum = .none
            todo.recurrenceEndDate = nil
            todo.recurrenceCount = nil
            todo.customRecurrenceData = nil
        }
    }
}

struct DaysOfWeekSelector: View {
    @Binding var selectedDays: [Int]
    let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    var body: some View {
        List {
            ForEach(1...7, id: \.self) { day in
                Button(action: {
                    if selectedDays.contains(day) {
                        selectedDays.removeAll(where: { $0 == day })
                    } else {
                        selectedDays.append(day)
                        selectedDays.sort()
                    }
                }) {
                    HStack {
                        Text(daysOfWeek[day - 1])
                        Spacer()
                        if selectedDays.contains(day) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
        }
        .navigationTitle("Select Days")
    }
}

#Preview {
    // Create a sample todo for preview
    let todo = Todo(title: "Sample Todo", dueDate: Date())
    
    return RecurrenceSelectorView(todo: todo)
}
