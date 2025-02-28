//
//  InboxView.swift
//  Polaris
//
//  Created by Kevin Perez on 12/26/24.
//

import SwiftUI
import SwiftData

struct InboxView: View {
	
	@Environment(\.modelContext) private var modelContext
	@Query(filter: #Predicate<Todo> { todo in
		todo.inbox == true && todo.status == false
		}, sort: \Todo.created, order: .forward) var todos: [Todo]
	@State var activeTodo: Todo? = nil
	@State private var newlyCreatedTodo: Todo? = nil
	
	var body: some View {
		NavigationView {
			ZStack {
				ScrollView(showsIndicators: false) {
					VStack {
						if todos.isEmpty {
							ContentUnavailableView {
								Label {
									Text("No tasks yet!")
								} icon: {
									Image(systemName: "tray.fill")
										.foregroundStyle(Color.blue)
								}
							} description: {
								Text("Way to go! You've completed all your tasks for today! Keep it up!")
							} actions: {
								Button {
									addNewTodo()
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
									withAnimation {
										if activeTodo == todo {
											activeTodo = nil
										} else {
											activeTodo = todo
										}
									}
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
								addNewTodo()
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
			#if os(iOS)
			.background(Color(.systemGroupedBackground))
			#endif
			.navigationTitle("Inbox")
		}
	}
	
	private func addNewTodo() {
		let newTodo = Todo(
			title: "",
			notes: "",
			status: false,
			dueDate: Date.now,
			deadLineDate: Date.now,
			inbox: true
		)
		modelContext.insert(newTodo)
		try? modelContext.save()
		newlyCreatedTodo = newTodo
		activeTodo = newTodo
	}
}

#Preview {
	ContentView()
}
