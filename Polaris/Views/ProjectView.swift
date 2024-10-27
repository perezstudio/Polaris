//
//  ProjectView.swift
//  Polaris
//
//  Created by Kevin Perez on 10/18/24.
//

import SwiftUI

struct ProjectView: View {
	
	@Bindable var project: Project
	@State var openCreateTaskSheet: Bool = false
	@State var openTaskDetailsInspector: Bool = false
	@State var selectedTask: Todo? = nil
	
    var body: some View {
		VStack {
			List {
				if(project.todos.isEmpty) {
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
					ForEach(project.todos) { todo in
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
			.navigationTitle(project.name)
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
				CreateTodoView(project: .constant(project))
			}
		}
    }
}

#Preview {
	
	var NewProject = Project(id: UUID(), name: "New Project", notes: "New Project Description", dueDate: Date.now, deadLine: Date.now, status: .inProgress, icon: "xmark.circle.fill", color: ProjectColors(rawValue: "red")!)
	
	ProjectView(project: NewProject)
}
