//
//  FilteredTodoView.swift
//  Polaris
//
//  Created by Kevin Perez on 10/27/24.
//

import SwiftUI
import SwiftData

struct FilteredTodoView: View {
	let filter: TodoFilter
	
	@Query private var todos: [Todo]
	@State var openTaskDetailsInspector: Bool = false
	@State var openCreateTaskSheet: Bool = false
	@State var selectedTask: Todo? = nil
	
	init(filter: TodoFilter) {
		self.filter = filter
		
		let now = Date()
		
		// Create compound predicates based on filter type
		let predicate: Predicate<Todo>
		switch filter {
		case .all:
			_todos = Query()
		case .inbox:
			_todos = Query(filter: #Predicate<Todo> { todo in
				todo.inbox == true && todo.status == false
			})
		case .today:
			_todos = Query(filter: #Predicate<Todo> { todo in
				todo.dueDate != nil && todo.status == false
			})
		case .upcoming:
			_todos = Query(filter: #Predicate<Todo> { todo in
				todo.dueDate != nil && todo.status == false
			})
		case .completed:
			_todos = Query(filter: #Predicate<Todo> { todo in
				todo.status == true
			})
		}
	}
	
	var body: some View {
		List {
			Section {
				if(todos.isEmpty) {
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
					ForEach(todos) { todo in
						TaskRowView(todo: todo)
					}
				}
			}
		}
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
		.navigationTitle(filter.title) // You'll need to add this computed property to the enum
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

// Add title property to enum
extension TodoFilter {
	var title: String {
		switch self {
		case .all: return "All Tasks"
		case .inbox: return "Inbox"
		case .today: return "Today"
		case .upcoming: return "Upcoming"
		case .completed: return "Completed"
		}
	}
}

#Preview {
	FilteredTodoView(filter: .inbox)
		.modelContainer(for: [Todo.self, Project.self], inMemory: true)
}
