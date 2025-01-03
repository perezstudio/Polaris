//
//  ProjectView.swift
//  Polaris
//
//  Created by Kevin Perez on 12/26/24.
//

import SwiftUI

struct ProjectView: View {
	
	@Environment(\.modelContext) private var modelContext
	@Bindable var project: Project
	@State var activeTodo: Todo? = nil
	@State private var newlyCreatedTodo: Todo? = nil
	
	var todos: [Todo] {
		project.todos ?? []
	}
	
	var body: some View {
		ZStack {
			ScrollView(showsIndicators: false) {
				VStack {
					if todos.isEmpty {
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
				// Add floating action button
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
	
}

//#Preview {
//    ProjectView()
//}
