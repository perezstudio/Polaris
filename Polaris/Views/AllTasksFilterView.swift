//
//  AllTasksFilterView.swift
//  Polaris
//
//  Created by Kevin Perez on 11/4/24.
//

import SwiftUI
import SwiftData

struct AllTasksFilterView: View {
	
	@Query(
		filter: #Predicate<Todo> { $0.status == false }
	) private var todos: [Todo]
	
	@State var openCreateTaskSheet: Bool = false
	@State var openTaskDetailsInspector: Bool = false
	@State var selectedTask: Todo? = nil
	
	// Helper function to get project name
	private func projectName(for todo: Todo) -> String {
		todo.project?.name ?? "No Project"
	}
	
	// Helper function to sort todos
	private func sortedTodos(_ todos: [Todo]) -> [Todo] {
		todos.sorted { first, second in
			guard let date1 = first.dueDate else { return true }
			guard let date2 = second.dueDate else { return false }
			return date1 < date2
		}
	}
	
	// Helper function to group todos
	private var groupedTasks: [(key: String, tasks: [Todo])] {
		// First group by project
		let grouped = Dictionary(grouping: todos, by: projectName)
		
		// Sort the keys to ensure "No Project" comes first
		let sortedKeys = grouped.keys.sorted()
		
		// Create final array with sorted tasks
		return sortedKeys.map { key in
			let tasks = sortedTodos(grouped[key] ?? [])
			return (key: key, tasks: tasks)
		}
	}
	
    var body: some View {
		List {
			if todos.isEmpty {
				ContentUnavailableView {
					Label("No Tasks", systemImage: "checkmark.square")
				} description: {
					Text("Create a new task to see it listed in your project.")
				} actions: {
					Button {
						openCreateTaskSheet.toggle()
					} label: {
						Label("Create New Task", systemImage: "plus.square")
					}
				}
			} else {
				ForEach(groupedTasks, id: \.key) { group in
					Section(group.key) {
						ForEach(group.tasks) { todo in
							Button {
								if(selectedTask == todo) {
									openTaskDetailsInspector.toggle()
								} else {
									selectedTask = todo
									openTaskDetailsInspector = true
								}
							} label: {
								TaskRowView(todo: todo)
							}
						}
					}
				}
			}
		}
		#if os(iOS)
		.toolbar {
			ToolbarItemGroup(placement: .bottomBar) {
				Spacer()
				Button {
					openCreateTaskSheet.toggle()
				} label: {
					Label("Create New Task", systemImage: "plus.square")
				}
			}
		}
		#endif
		.navigationTitle("All My Tasks")
		.navigationBarTitleDisplayMode(.large)
		.inspector(isPresented: $openTaskDetailsInspector) {
			if let task = selectedTask {
				TaskDetailsView(todo: task)
			} else {
				ContentUnavailableView("No Task Selected",
					systemImage: "checklist")
			}
		}
		.sheet(isPresented: $openCreateTaskSheet) {
			CreateTodoView()
		}
    }
}

//#Preview {
//    AllTasksFilterView()
//}
