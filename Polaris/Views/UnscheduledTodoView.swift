//
//  UnscheduledTodoView.swift
//  Polaris
//
//  Created by Kevin Perez on 12/27/24.
//

import SwiftUI
import SwiftData

struct UnscheduledTodoView: View {
	
	@Environment(\.dismiss) var dismiss
	
	@Query(filter: #Predicate<Todo> { $0.dueDate == nil }, sort: \Todo.created, order: .forward)
	var unscheduledTodos: [Todo]
	@State var activeTodo: Todo? = nil
	@State private var newlyCreatedTodo: Todo? = nil
	
	var body: some View {
		NavigationStack {
			ScrollView(showsIndicators: false) {
				VStack {
					if (!unscheduledTodos.isEmpty) {
						ForEach(unscheduledTodos) { todo in
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
					} else {
						ContentUnavailableView {
							Label {
								Text("No Unscheduled Todos")
							} icon: {
								Image(systemName: "calendar.badge.clock")
									.foregroundStyle(Color.red)
							}
						} description: {
							Text("There are no unscheduled todos. You're all caught up!")
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
			.navigationTitle("Unscheduled")
			#if os(iOS)
			.background(Color(.systemGroupedBackground))
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button {
						dismiss()
					} label: {
						Text("Done")
					}
				}
			}
			#endif
		}
	}
}

#Preview {
	UnscheduledTodoView()
}
