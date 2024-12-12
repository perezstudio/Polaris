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
	@State var openEditProjectSheet: Bool = false
	@State private var showCompletedTasks: Bool = false
	
	private var incompleteTasks: [Todo] {
		project.todos.filter { !$0.status }
	}
	
	private var completedTasks: [Todo] {
		project.todos.filter { $0.status }
	}
	
	var body: some View {
		VStack {
			List {
				if(project.todos.isEmpty || (!showCompletedTasks && incompleteTasks.isEmpty)) {
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
					Section {
						ForEach(incompleteTasks) { todo in
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
					
					if showCompletedTasks && !completedTasks.isEmpty {
						Section("Completed Tasks") {
							ForEach(completedTasks) { todo in
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
			.navigationTitle(project.name)
			#if os(iOS)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Menu {
						Button {
							showCompletedTasks.toggle()
						} label: {
							Label(
								showCompletedTasks ? "Hide Completed Tasks" : "Show Completed Tasks",
								systemImage: showCompletedTasks ? "eye.slash" : "eye"
							)
						}
						Button {
							openEditProjectSheet.toggle()
						} label: {
							Label("Edit Project", systemImage: "pencil")
						}
					} label: {
						Label("Project Options", systemImage: "ellipsis.circle")
					}
				}
				ToolbarItemGroup(placement: .bottomBar) {
					Spacer()
					Button {
						openCreateTaskSheet.toggle()
					} label: {
						Label("Create New Task", systemImage: "plus.square")
					}
				}
			}
			.navigationBarTitleDisplayMode(.large)
			#endif
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
			.sheet(isPresented: $openEditProjectSheet) {
				CreateProjectView(project: project)
			}
		}
	}
}

#Preview {
	
	let NewProject = Project(id: UUID(), name: "New Project", notes: "New Project Description", dueDate: Date.now, deadLine: Date.now, status: .inProgress, icon: "xmark.circle.fill", color: ProjectColors(rawValue: "red")!)
	
	ProjectView(project: NewProject)
}
