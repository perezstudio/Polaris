//
//  ScheduledView.swift
//  Polaris
//
//  Created by Kevin Perez on 5/5/25.
//

import SwiftUI
import SwiftData

struct ScheduledView: View {
	
	@Environment(\.modelContext) private var modelContext
	@Query private var allTodos: [Todo] // fetch all
	@State private var showDateSelector: Bool = false
	@State private var selectedYear: Int
	@State private var selectedMonth: Int
	@State private var selectedDay: Int

	// Range for years to display
	let years: [Int]
	let months = Calendar.current.monthSymbols

	init() {
		let calendar = Calendar.current
		let date = Date()
		let year = calendar.component(.year, from: date)
		let month = calendar.component(.month, from: date)
		let day = calendar.component(.day, from: date)

		_selectedYear = State(initialValue: year)
		_selectedMonth = State(initialValue: month)
		_selectedDay = State(initialValue: day)

		self.years = Array((year - 5)...(year + 10))
	}

	private var selectedDate: Date {
		var components = DateComponents()
		components.year = selectedYear
		components.month = selectedMonth
		components.day = selectedDay
		return Calendar.current.date(from: components) ?? Date()
	}

	private var todos: [Todo] {
		let calendar = Calendar.current
		let selectedStart = calendar.startOfDay(for: selectedDate)
		let selectedEnd = calendar.date(byAdding: .day, value: 1, to: selectedStart)!

		return allTodos.filter { todo in
			let dueMatch = todo.dueDate.map {
				let day = calendar.startOfDay(for: $0)
				return day >= selectedStart && day < selectedEnd
			} ?? false

			let deadlineMatch = todo.deadline.map {
				let day = calendar.startOfDay(for: $0)
				return day >= selectedStart && day < selectedEnd
			} ?? false

			return dueMatch || deadlineMatch
		}
	}

	var body: some View {
		NavigationStack {
			List {
				if !todos.isEmpty {
					SwiftUI.Section {
						ForEach(todos) { todo in
							TodoListView(todo: todo)
						}
					}
				} else {
					ContentUnavailableView(
						"No Todos Scheduled",
						systemImage: "calendar.badge.exclamationmark",
						description: Text("You're free for this day!")
					)
				}
			}
			.navigationTitle(formattedDateTitle)
			.navigationBarTitleDisplayMode(.large)
			.toolbar {
				ToolbarItemGroup(placement: .bottomBar) {
					Button {
						showDateSelector.toggle()
					} label: {
						Label("Open Calendar", systemImage: "calendar.day.timeline.left")
							.labelStyle(.iconOnly)
					}
					Spacer()
					Button {
						let calendar = Calendar.current
						let today = Date()
						selectedYear = calendar.component(.year, from: today)
						selectedMonth = calendar.component(.month, from: today)
						selectedDay = calendar.component(.day, from: today)
					} label: {
						Label("Today", systemImage: "calendar.circle")
					}
					Spacer()
					Button {
						print("Create Todo")
					} label: {
						Label("New Todo", systemImage: "plus.square.fill")
					}
				}
			}
			.sheet(isPresented: $showDateSelector) {
				DateSelectorView(
					selectedYear: $selectedYear,
					selectedMonth: $selectedMonth,
					selectedDay: $selectedDay
				)
				.presentationDetents([.fraction(0.40)])
			}
			.onChange(of: selectedDate) { oldValue, newValue in
				let calendar = Calendar.current
				selectedYear = calendar.component(.year, from: newValue)
				selectedMonth = calendar.component(.month, from: newValue)
				selectedDay = calendar.component(.day, from: newValue)
			}
		}
	}

	private var formattedDateTitle: String {
		let formatter = DateFormatter()
		formatter.dateFormat = "EEEE, MMMM d"
		return formatter.string(from: selectedDate)
	}
}

#Preview {
	ScheduledView()
}
