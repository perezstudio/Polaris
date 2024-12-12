//
//  InboxFilterView.swift
//  Polaris
//
//  Created by Kevin Perez on 11/4/24.
//

import SwiftUI
import SwiftData

struct InboxFilterView: View {
	
	@Query(
			filter: #Predicate<Todo> {
				$0.inbox && !$0.status
			},
			sort: [
				SortDescriptor(\Todo.createdDate, order: .reverse)
			]
		) private var todos: [Todo]
	@State var openCreateTaskSheet: Bool = false
	@State var openTaskDetailsInspector: Bool = false
	@State var selectedTask: Todo? = nil
	
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
			#endif
		}
		.navigationTitle("Inbox")
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
//    InboxFilterView()
//}
