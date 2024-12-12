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
			TaskListContent(
				todos: todos,
				groupedTasks: groupedTasks,
				selectedTask: $selectedTask,
				openTaskDetailsInspector: $openTaskDetailsInspector,
				openCreateTaskSheet: $openCreateTaskSheet
			)
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
		#if os(iOS)
		.navigationBarTitleDisplayMode(.large)
		#endif
		.inspector(isPresented: $openTaskDetailsInspector) {
			if let task = selectedTask {
				TaskDetailsView(todo: task, sheetState: $openTaskDetailsInspector)
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
