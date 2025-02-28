//
//  UpcomingView.swift
//  Polaris
//
//  Created by Kevin Perez on 12/26/24.
//

import SwiftUI
import SwiftData

struct UpcomingView: View {
	
	@Environment(\.modelContext) private var modelContext
	
	// Query all todos without filtering
	@Query(sort: \Todo.created, order: .forward) private var allTodos: [Todo]
	
	// States for date selection
	@State private var selectedMonth: Int = Calendar.current.component(.month, from: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
	@State private var selectedDay: Int = Calendar.current.component(.day, from: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
	@State private var selectedYear: Int = Calendar.current.component(.year, from: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
	@State private var displayDateSelector: Bool = false
	@State var overdueTodosSheet: Bool = false
	@State var unscheduledTodosSheet: Bool = false
	@State private var activeTodo: Todo? = nil
	@State private var newlyCreatedTodo: Todo? = nil
	
	// Dynamic title based on selected date
	var formattedTitle: String {
		let calendar = Calendar.current
		
		// Construct date from selected components
		let dateComponents = DateComponents(year: selectedYear, month: selectedMonth, day: selectedDay)
		if let date = calendar.date(from: dateComponents) {
			let formatter = DateFormatter()
			
			// Format the date to match "ddd, MMM d, YYYY"
			formatter.dateFormat = "EEE. MMM d, yyyy" // Example: "Mon, Aug 22, 2025"
			
			return formatter.string(from: date)
		}
		return "Select a Date"
	}
	
	// Filtered todos based on selected date
	var filteredTodos: [Todo] {
		allTodos.filter { todo in
			todo.dueDateYear == selectedYear &&
			todo.dueDateMonth == selectedMonth &&
			todo.dueDateDay == selectedDay
		}
	}
	
	var unscheduledTodos: [Todo] {
		allTodos.filter { todo in
			todo.dueDate == nil
		}
	}
	
	// Filtered list of overdue todos
	var overdueTodos: [Todo] {
		let calendar = Calendar.current
		
		// Calculate the start of today (12:00 AM)
		let startOfToday = calendar.startOfDay(for: Date.now)
		
		return allTodos.filter { todo in
			// Include only todos with a dueDate before the start of today
			if let dueDate = todo.dueDate {
				return dueDate < startOfToday // Compare against 12:00 AM today
			}
			return false // Exclude todos with nil due dates
		}
	}
	
	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				// Scrollable Content
				ZStack {
					ScrollView(showsIndicators: false) {
						VStack(spacing: 16) {
							if filteredTodos.isEmpty {
								ContentUnavailableView {
									Label {
										Text("No tasks yet!")
									} icon: {
										Image(systemName: "calendar.badge.clock")
											.foregroundStyle(Color.red)
									}
								} description: {
									Text("There's no scheduled tasks for this day. Keep up the productive work!")
								} actions: {
									Button {
										addNewTodo()
									} label: {
										Label("Create New Task", systemImage: "plus")
									}
								}
							} else {
								ForEach(filteredTodos) { todo in
									TodoCard(
										todo: todo,
										showDetails: .constant(activeTodo == todo),
										isNewTodo: todo == newlyCreatedTodo
									)
									.onTapGesture {
										withAnimation {
											if activeTodo == todo {
												activeTodo = nil
												newlyCreatedTodo = nil
											} else {
												activeTodo = todo
												displayDateSelector = false
											}
										}
									}
								}
							}
						}
					}
					if (activeTodo == nil) {
						// Add floating action button
						VStack {
							Spacer()
							HStack {
								Button {
									withAnimation {
										displayDateSelector.toggle()
									}
								} label: {
									Image(systemName: displayDateSelector ? "xmark.circle.fill" : "timelapse")
										.font(.title2)
										.fontWeight(.semibold)
										.foregroundColor(.white)
										.frame(width: 56, height: 56)
										.background(.red)
										.clipShape(Circle())
										.shadow(radius: 4)
								}
								.padding(.leading, 20)
								.padding(.bottom, 20)
								Spacer()
								Button {
									addNewTodo()
								} label: {
									Image(systemName: "plus")
										.font(.title2)
										.fontWeight(.semibold)
										.foregroundColor(.white)
										.frame(width: 56, height: 56)
										.background(Color.blue)
										.clipShape(Circle())
										.shadow(radius: 4)
								}
								.padding(.trailing, 20)
								.padding(.bottom, 20)
							}
						}
					}
				}
				.onTapGesture {
					withAnimation {
						activeTodo = nil
						newlyCreatedTodo = nil
					}
				}
				.onChange(of: activeTodo) { _, newValue in
					if newValue == nil {
						newlyCreatedTodo = nil
					}
				}
				
				if (displayDateSelector) {
					// Date Selector with Handle
					VStack(spacing: 8) {
						
						// Year Selector
						YearScrollView(selectedYear: $selectedYear)
						
						// Month Selector
						MonthScrollView(selectedMonth: $selectedMonth)
						
						// Day Selector
						DayScrollView(selectedYear: $selectedYear, selectedMonth: $selectedMonth, selectedDay: $selectedDay)
					}
					.padding(.vertical, 8)
					#if os(iOS)
					.background(Color(.secondarySystemGroupedBackground))
					#endif
				}
			}
			.navigationTitle(formattedTitle)
			#if os(iOS)
			.background(Color(.systemGroupedBackground))
			.navigationBarTitleDisplayMode(.large)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button {
						selectedYear = Calendar.current.component(.year, from: Date())
						selectedMonth = Calendar.current.component(.month, from: Date())
						selectedDay = Calendar.current.component(.day, from: Date())
					} label: {
						Label("Go To Today", systemImage: "calendar.circle")
					}
				}
				ToolbarItemGroup(placement: .topBarTrailing) {
					if (!unscheduledTodos.isEmpty) {
						Button {
							unscheduledTodosSheet.toggle()
						} label: {
							Label("See Unscheduled", systemImage: "calendar.badge.clock")
						}
					}
					if (!overdueTodos.isEmpty) {
						Button {
							overdueTodosSheet.toggle()
						} label: {
							Label("See Overdue", systemImage: "calendar.badge.exclamationmark")
						}
					}
				}
			}
			#endif
			.sheet(isPresented: $unscheduledTodosSheet) {
				UnscheduledTodoView()
			}
			.sheet(isPresented: $overdueTodosSheet) {
				OverdueTodoView()
			}
		}
	}
	
	private func addNewTodo() {
		// Define a calendar inside the function
		let calendar = Calendar.current
		
		// Create a date using the selected year, month, and day
		let selectedDateComponents = DateComponents(
			year: selectedYear,
			month: selectedMonth,
			day: selectedDay
		)
		
		// Convert the date components into a Date object
		guard let selectedDate = calendar.date(from: selectedDateComponents) else {
			print("Invalid date components")
			return
		}
		
		// Create a new todo with the selected due date
		let newTodo = Todo(
			title: "",
			notes: "",
			status: false,
			dueDate: selectedDate, // Use the selected date
			deadLineDate: nil,
			inbox: false
		)
		
		// Insert into the model context
		modelContext.insert(newTodo)
		try? modelContext.save()
		
		// Update UI state
		withAnimation {
			activeTodo = newTodo
			newlyCreatedTodo = newTodo
			displayDateSelector = false
		}
	}
	
}

#Preview {
	UpcomingView()
}
