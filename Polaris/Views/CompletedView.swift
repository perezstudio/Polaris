//
//  CompletedView.swift
//  Polaris
//
//  Created by Kevin Perez on 12/26/24.
//

import SwiftUI
import SwiftData

struct CompletedView: View {
	
	@Environment(\.modelContext) private var modelContext
	@Query(filter: #Predicate<Todo> { $0.status == true }, sort: \Todo.created, order: .reverse) var completedTodos: [Todo]
	@State var activeTodo: Todo? = nil
	@State private var newlyCreatedTodo: Todo? = nil
	
	var body: some View {
		ZStack {
			ScrollView {
				VStack(alignment: .leading, spacing: 16) {
					if completedTodos.isEmpty {
						ContentUnavailableView {
							Label {
								Text("No tasks completed yet!")
							} icon: {
								Image(systemName: "checkmark.circle.fill")
									.foregroundStyle(Color.green)
							}
						} description: {
							Text("You're barely getting started but you'll get your work completed in no time!")
						} actions: {
							Button {
								addNewTodo()
							} label: {
								Label("Create New Task", systemImage: "plus")
							}
						}
					} else {
						// Group todos by the 'created' date
						let groupedTodos = Dictionary(grouping: completedTodos) { todo in
							Calendar.current.startOfDay(for: todo.created) // Group by date
						}
						
						// Sort the groups by date
						let sortedDates = groupedTodos.keys.sorted(by: >)
						
						ForEach(sortedDates, id: \.self) { date in
							// Section Header
							VStack(alignment: .leading, spacing: 8) {
								// Date Header
								HStack {
									Text(formattedDate(date))
										.font(.headline)
										.foregroundColor(.secondary)
									Spacer()
								}
								.padding(.horizontal)
								
								// Todos for this date
								VStack(spacing: 8) {
									ForEach(groupedTodos[date] ?? []) { todo in
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
			
			// Floating Action Button
			if activeTodo == nil {
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
		.navigationTitle("Completed")
		#if os(iOS)
		.background(Color(.systemGroupedBackground))
		.navigationBarTitleDisplayMode(.large)
		#endif
	}
	
	// Function to format the date into a readable string
	private func formattedDate(_ date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "EEEE, MMM d" // Example: "Monday, Aug 22"
		return formatter.string(from: date)
	}
	
	// Adds a new todo
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
	CompletedView()
}
