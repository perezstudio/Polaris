//
//  ProjectView.swift
//  Polaris
//
//  Created by Kevin Perez on 12/26/24.
//

import SwiftUI
import SwiftData

struct ProjectView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	@Bindable var project: Project
	@State var editProjectSheet: Bool = false
	@State var activeTodo: Todo? = nil
	@State private var newlyCreatedTodo: Todo? = nil
	@State private var sortOrder: SortOrder = .title
	@State private var showCompletedTodos = false

	// Create an enum for sort order
	enum SortOrder {
		case title
		case dueDate
	}

	// Modified todos computed property with sorting
	var todos: [Todo] {
		let incompleteTodos = (project.todos ?? []).filter { !$0.status }
		switch sortOrder {
		case .title:
			return incompleteTodos.sorted { $0.title < $1.title }
		case .dueDate:
			return incompleteTodos.sorted {
				// This will put nil dates at the end
				guard let date1 = $0.dueDate, let date2 = $1.dueDate else {
					return $0.dueDate != nil
				}
				return date1 < date2
			}
		}
	}

	// Add completed todos computed property
	var completedTodos: [Todo] {
		return (project.todos ?? [])
			.filter { $0.status }
			.sorted { $0.title < $1.title }
	}

	// Add delete project function
	private func deleteProject() {
		// Delete all associated todos first
		for todo in project.todos ?? [] {
			modelContext.delete(todo)
		}
		// Delete the project
		modelContext.delete(project)
		try? modelContext.save()
		dismiss() // Go back to previous view
	}

	// Add archive project function
	private func archiveProject() {
		project.status = Status.Archived
		try? modelContext.save()
		dismiss() // Go back to previous view
	}

	private func toggleActive(_ todo: Todo) {
		withAnimation {
			if activeTodo == todo {
				activeTodo = nil
			} else {
				activeTodo = todo
			}
		}
	}

	private func addNewTodo(activeProject: Project) {
		let newTodo = Todo(
			title: "",
			notes: "",
			status: false,
			dueDate: Date.now,
			deadLineDate: Date.now,
			inbox: true
		)
		modelContext.insert(newTodo) // Insert the new todo into the context
		newTodo.project = [activeProject] // Assign the project to the new todo
		newlyCreatedTodo = newTodo // Set the newly created todo
		activeTodo = newTodo // Make it the active todo
		try? modelContext.save()
	}

	var body: some View {
		ZStack {
			ScrollView(showsIndicators: false) {
				VStack {
					if todos.isEmpty && !showCompletedTodos {
						ContentUnavailableView {
							Label {
								Text("No tasks yet!")
							} icon: {
								Image(systemName: project.icon)
									.foregroundStyle(project.color.color)
							}
						} description: {
							Text("Way to go! You've completed all your project tasks! Keep it up!")
						} actions: {
							Button {
								addNewTodo(activeProject: project)
							} label: {
								Label("Create New Task", systemImage: "plus")
							}
						}
					} else {
						// Active todos section
						VStack(alignment: .leading, spacing: 16) {
							if !todos.isEmpty {
								
								ForEach(todos) { todo in
									TodoCard(
										todo: todo,
										showDetails: .constant(activeTodo == todo),
										isNewTodo: todo == newlyCreatedTodo
									)
									.onTapGesture {
										toggleActive(todo)
									}
								}
							}
						}

						// Completed todos section
						if showCompletedTodos && !completedTodos.isEmpty {
							VStack(alignment: .leading, spacing: 16) {
								HStack {
									Text("Completed Todos")
										.font(.headline)
										.foregroundColor(.secondary)
									Spacer()
								}
								.padding(.horizontal)
								
								ForEach(completedTodos) { todo in
									TodoCard(
										todo: todo,
										showDetails: .constant(activeTodo == todo),
										isNewTodo: todo == newlyCreatedTodo
									)
									.onTapGesture {
										toggleActive(todo)
									}
								}
							}
							.padding(.top)
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

			if (activeTodo == nil) {
				VStack {
					Spacer()
					HStack {
						Spacer()
						Button {
							addNewTodo(activeProject: project)
						} label: {
							Image(systemName: "plus")
								.font(.title2)
								.fontWeight(.semibold)
								.foregroundColor(.white)
								.frame(width: 56, height: 56)
								.background(Color.blue)
								.clipShape(Circle())
								.shadow(radius: 4)
						}
						.padding(.trailing, 20)
						.padding(.bottom, 20)
					}
				}
			}
		}
		.background(Color(.systemGroupedBackground))
		.navigationTitle(project.title)
		.navigationBarTitleDisplayMode(.large)
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Menu {
					Button(action: {
						editProjectSheet.toggle()
					}) {
						Label("Edit Project", systemImage: "pencil.line")
					}

					Menu("Sort By") {
						Button(action: {
							sortOrder = .title
						}) {
							Label("Title", systemImage: "textformat")
						}
						
						Button(action: {
							sortOrder = .dueDate
						}) {
							Label("Due Date", systemImage: "calendar")
						}
					}

					Button(action: {
						showCompletedTodos.toggle()
					}) {
						Label(
							showCompletedTodos ? "Hide Completed Todos" : "Show Completed Todos",
							systemImage: showCompletedTodos ? "eye.slash" : "eye"
						)
					}

					Button(action: {
						archiveProject()
					}) {
						Label("Archive Project", systemImage: "archivebox")
					}

					Button(role: .destructive, action: {
						deleteProject()
					}) {
						Label("Delete Project", systemImage: "trash")
					}
				} label: {
					Label("Settings", systemImage: "ellipsis")
				}
			}
		}
		.sheet(isPresented: $editProjectSheet) {
			CreateProjectSheet(projectToEdit: project)
		}
	}
}

#Preview {
	ProjectView(project: Project(title: "Preview Project", icon: "star", color: .red))
}
