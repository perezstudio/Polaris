//
//  TodayFilterView.swift
//  Polaris
//
//  Created by Kevin Perez on 11/4/24.
//

import SwiftUI
import SwiftData

struct TodayFilterView: View {
	
	// Update the Query predicate to use simple date comparison
	@Query(filter: #Predicate<Todo> { todo in
		todo.status == false &&    // Not completed
		todo.dueDate != nil       // Has a due date
		},
		   sort: \Todo.dueDate) private var todos: [Todo]
	
	@State var openCreateTaskSheet: Bool = false
	@State var openTaskDetailsInspector: Bool = false
	@State var selectedTask: Todo? = nil
	
	// Update todayTasks to handle the date filtering
	private var todayTasks: [Todo] {
		let calendar = Calendar.current
		let endOfDay = calendar.startOfDay(for: .now).addingTimeInterval(24*60*60 - 1)
		
		return todos.filter { todo in
			guard let dueDate = todo.dueDate else { return false }
			return dueDate <= endOfDay
		}
	}
	
	var body: some View {
		List {
			Section {
				if(todayTasks.isEmpty) {  // Changed from todos to todayTasks
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
					ForEach(todayTasks) { todo in  // Changed from todos to todayTasks
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
		.toolbar {
#if os(iOS)
			ToolbarItemGroup(placement: .bottomBar) {
				Spacer()
				Button {
					openCreateTaskSheet.toggle()
				} label: {
					Label("Create New Task", systemImage: "plus.square")
				}
			}
			#elseif os(macOS)
			ToolbarItem(placement: .primaryAction) {
				Button {
					openCreateTaskSheet.toggle()
				} label: {
					Label("Create New Task", systemImage: "plus.square")
				}
			}
#endif
		}
		.navigationTitle("Today")
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
//	NavigationStack {
//		TodayFilterView()
//			.modelContainer(for: Todo.self, inMemory: true)
//	}
//}
