//
//  ProjectView.swift
//  Polaris
//
//  Created by Kevin Perez on 10/18/24.
//

import SwiftUI

enum TaskSortParameter {
	case defaultSort, dueDate, deadline, createdDate, title
	
	var name: String {
		switch self {
		case .defaultSort: return "Default"
		case .dueDate: return "Due Date"
		case .deadline: return "Deadline"
		case .createdDate: return "Created Date"
		case .title: return "Title"
		}
	}
}

struct ProjectTasksList: View {
	let incompleteTasks: [Todo]
	let completedTasks: [Todo]
	let showCompletedTasks: Bool
	@Binding var selectedTask: Todo?
	@Binding var openTaskDetailsInspector: Bool
	@Binding var openCreateTaskSheet: Bool
	
	var body: some View {
		List {
			if incompleteTasks.isEmpty && (!showCompletedTasks || completedTasks.isEmpty) {
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
							if selectedTask == todo {
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
								if selectedTask == todo {
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
	}
}

struct ProjectView: View {
	
	@Bindable var project: Project
	@State var openCreateTaskSheet: Bool = false
	@State var openTaskDetailsInspector: Bool = false
	@State var selectedTask: Todo? = nil
	@State var openEditProjectSheet: Bool = false
	@State private var showCompletedTasks: Bool = false
	@State private var sortAscending: Bool = true
	@State private var sortParameter: TaskSortParameter = .defaultSort
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	@State private var showDeleteConfirmation = false
	
	private var incompleteTasks: [Todo] {
		let filtered = project.todos.filter { !$0.status }
		
		guard sortParameter != .defaultSort else { return filtered }
		
		return filtered.sorted { (todo1: Todo, todo2: Todo) -> Bool in
			let comparison: Bool = switch sortParameter {
			case .defaultSort:
				true
			case .dueDate:
				(todo1.dueDate ?? .distantFuture) < (todo2.dueDate ?? .distantFuture)
			case .deadline:
				(todo1.deadLine ?? .distantFuture) < (todo2.deadLine ?? .distantFuture)
			case .createdDate:
				todo1.createdDate < todo2.createdDate
			case .title:
				todo1.title.localizedCompare(todo2.title) == .orderedAscending
			}
			return sortAscending ? comparison : !comparison
		}
	}
	
	private var completedTasks: [Todo] {
		let filtered = project.todos.filter { $0.status }
		
		guard sortParameter != .defaultSort else { return filtered }
		
		return filtered.sorted { (todo1: Todo, todo2: Todo) -> Bool in
			let comparison: Bool = switch sortParameter {
			case .defaultSort:
				true
			case .dueDate:
				(todo1.dueDate ?? .distantFuture) < (todo2.dueDate ?? .distantFuture)
			case .deadline:
				(todo1.deadLine ?? .distantFuture) < (todo2.deadLine ?? .distantFuture)
			case .createdDate:
				todo1.createdDate < todo2.createdDate
			case .title:
				todo1.title.localizedCompare(todo2.title) == .orderedAscending
			}
			return sortAscending ? comparison : !comparison
		}
	}
	
	var body: some View {
		VStack {
			ProjectTasksList(
				incompleteTasks: incompleteTasks,
				completedTasks: completedTasks,
				showCompletedTasks: showCompletedTasks,
				selectedTask: $selectedTask,
				openTaskDetailsInspector: $openTaskDetailsInspector,
				openCreateTaskSheet: $openCreateTaskSheet
			)
			.navigationTitle(project.name)
			#if os(iOS)
			.navigationBarTitleDisplayMode(.large)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Menu {
						Button {
							openEditProjectSheet.toggle()
						} label: {
							Label("Edit Project", systemImage: "pencil")
						}
						Button {
							showCompletedTasks.toggle()
						} label: {
							Label(
								showCompletedTasks ? "Hide Completed Tasks" : "Show Completed Tasks",
								systemImage: showCompletedTasks ? "eye.slash" : "eye"
							)
						}
						Menu {
							Picker("Sort Parameter", selection: $sortParameter) {
								ForEach([TaskSortParameter.defaultSort, .dueDate, .deadline, .createdDate, .title], id: \.self) { param in
									Text(param.name).tag(param)
								}
							}
							
							Button {
								sortAscending.toggle()
							} label: {
								Label(
									sortAscending ? "Sort Descending" : "Sort Ascending",
									systemImage: sortAscending ? "arrow.up" : "arrow.down"
								)
							}
						} label: {
							Label("Sort Tasks", systemImage: "arrow.up.arrow.down")
						}
						Divider()
						Button {
							project.status = .archived
						} label: {
							Label("Archive Project", systemImage: "archivebox")
						}
						
						Button(role: .destructive) {
							showDeleteConfirmation = true
						} label: {
							Label("Delete Project", systemImage: "trash")
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
			#endif
			.sheet(isPresented: $openTaskDetailsInspector) {
				if let task = selectedTask {
					TaskDetailsView(todo: task, sheetState: $openTaskDetailsInspector)
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
			.alert("Delete Project?", isPresented: $showDeleteConfirmation) {
				Button("Cancel", role: .cancel) {}
				Button("Delete", role: .destructive) {
					project.todos.forEach { modelContext.delete($0) }
					modelContext.delete(project)
					dismiss()
				}
			} message: {
				Text("This will permanently delete this project and all its tasks. This action cannot be undone.")
			}
		}
	}
}

#Preview {
	
	let NewProject = Project(id: UUID(), name: "New Project", notes: "New Project Description", dueDate: Date.now, deadLine: Date.now, status: .inProgress, icon: "xmark.circle.fill", color: ProjectColors(rawValue: "red")!)
	
	ProjectView(project: NewProject)
}
