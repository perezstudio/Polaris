//
//  OverdueTodoView.swift
//  Polaris
//
//  Created by Kevin Perez on 12/27/24.
//

import SwiftUI
import SwiftData

struct OverdueTodoView: View {
	
	@Environment(\.dismiss) var dismiss
	
	// Fetch all todos without filtering
	@Query(sort: \Todo.created, order: .forward) var allTodos: [Todo]
	
	@State var activeTodo: Todo? = nil
	@State private var newlyCreatedTodo: Todo? = nil
	
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
			ScrollView(showsIndicators: false) {
				VStack {
					if !overdueTodos.isEmpty {
						ForEach(overdueTodos) { todo in
							TodoCard(
								todo: todo,
								showDetails: .constant(activeTodo == todo),
								isNewTodo: todo == newlyCreatedTodo
							)
							.onTapGesture {
								withAnimation {
									if activeTodo == todo {
										activeTodo = nil
									} else {
										activeTodo = todo
									}
								}
							}
						}
					} else {
						ContentUnavailableView {
							Label {
								Text("No Overdue Todos")
							} icon: {
								Image(systemName: "calendar.badge.clock")
									.foregroundStyle(Color.red)
							}
						} description: {
							Text("There are no overdue todos. You're all caught up!")
						}
					}
				}
			}
			.onTapGesture {
				withAnimation {
					activeTodo = nil
				}
			}
			.onChange(of: activeTodo) { _, newValue in
				if newValue == nil {
					newlyCreatedTodo = nil
				}
			}
			.navigationTitle("Overdue")
			#if os(iOS)
			.background(Color(.systemGroupedBackground))
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button {
						dismiss()
					} label: {
						Text("Done")
					}
				}
			}
			#endif
		}
	}
}

#Preview {
	OverdueTodoView()
}
