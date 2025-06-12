//
//  TodayView.swift
//  Polaris
//
//  Created by Kevin Perez on 5/5/25.
//

import SwiftUI
import SwiftData

struct TodayView: View {
	
	@Query(filter: #Predicate<Todo> { !$0.isCompleted }) private var allTodos: [Todo]

	var todos: [Todo] {
		let calendar = Calendar.current
		let today = calendar.startOfDay(for: Date())
		let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
		
		return allTodos.filter { todo in
			let due = todo.dueDate.map { calendar.startOfDay(for: $0) < tomorrow } ?? false
			let deadline = todo.deadline.map { calendar.startOfDay(for: $0) < tomorrow } ?? false
			return due || deadline
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
						"No Todos Left",
						systemImage: "checkmark.circle",
						description: Text("Great Job! You're all done for the day!")
					)
				}
			}
			.navigationTitle("Today")
			#if os(iOS)
			.navigationBarTitleDisplayMode(.large)
			.toolbar {
				ToolbarItemGroup(placement: .bottomBar) {
					Spacer()
					Button {
						print("Create Todo")
					} label: {
						Label("New Todo", systemImage: "plus.square.fill")
					}
				}
			}
			#elseif os(macOS)
			.toolbar {
				ToolbarItemGroup(placement: .navigation) {
					Button {
						print("Create Todo")
					} label: {
						Label("New Todo", systemImage: "plus.square.fill")
					}
				}
			}
			#endif
		}
	}
}

#Preview {
	TodayView()
}
