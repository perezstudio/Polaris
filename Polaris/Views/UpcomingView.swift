//
//  UpcomingView.swift
//  Polaris
//
//  Created by Kevin Perez on 12/26/24.
//

import SwiftUI
import SwiftData

// MARK: - Main View
struct UpcomingView: View {
	
	@Environment(\.modelContext) private var modelContext
	@Query(sort: \Todo.created, order: .forward) var allTodos: [Todo]
	@State var activeTodo: Todo? = nil
	@State private var newlyCreatedTodo: Todo? = nil
	@State var unscheduledTodoSheet: Bool = false
	@State var overdueTodoSheet: Bool = false
	
	// Use 1-based indexing for months
	@State private var selectedMonth = Calendar.current.component(.month, from: Date())
	@State private var selectedDay: Int = Calendar.current.component(.day, from: Date())
	
	var formattedTitle: String {
		let calendar = Calendar.current
		let currentYear = calendar.component(.year, from: Date())
		
		// Create date components for selected month and day
		let dateComponents = DateComponents(year: currentYear, month: selectedMonth, day: selectedDay)
		if let date = calendar.date(from: dateComponents) {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "EEEE, MMM d" // Example: "Monday, Aug 22"
			return dateFormatter.string(from: date)
		}
		return "Select a Date"
	}
	
	var body: some View {
		NavigationStack {
			VStack {
				ScrollView {
					VStack {
						VStack {
							Text("Testing Task")
						}
					}
				}
				VStack(spacing: 8) {
					// Month Selector
					MonthScrollView(selectedMonth: $selectedMonth)
					
					// Day Selector
					DayScrollView(selectedMonth: $selectedMonth, selectedDay: $selectedDay)
				}
				.padding()
			}
			.navigationTitle(formattedTitle)
		}
	}
}

#Preview {
	UpcomingView()
}
