//
//  TodayView.swift
//  Polaris
//
//  Created by Kevin Perez on 12/26/24.
//

import SwiftUI
import SwiftData

extension Date {
	var startOfDay: Date {
		Calendar.current.startOfDay(for: self)
	}
}

struct TodayView: View {
	
	@Environment(\.modelContext) private var modelContext
	// Updated Query with basic date comparison
	@Query(filter: #Predicate<Todo> { todo in
		todo.dueDate != nil && todo.status == false
	}, sort: \Todo.created) var todos: [Todo]
	@State private var activeTodo: Todo? = nil
	@State private var newlyCreatedTodo: Todo? = nil
	
	// Filter todos for today in the view layer
	private var todayTodos: [Todo] {
		todos.filter { todo in
			guard let dueDate = todo.dueDate else { return false }
			return Calendar.current.isDateInToday(dueDate)
		}
	}
	
	var body: some View {
		NavigationStack {
			ZStack {
				mainContent
				if activeTodo == nil {
					floatingActionButton
				}
			}
			.background(Color(.systemGroupedBackground))
			.navigationTitle("Today")
		}
	}
	
	// MARK: - View Components
	
	private var mainContent: some View {
		ScrollView(showsIndicators: false) {
			VStack {
				if todayTodos.isEmpty {
					emptyStateView
				} else {
					todoListView
				}
			}
		}
		.onTapGesture {
			withAnimation {
				activeTodo = nil
				newlyCreatedTodo = nil
			}
		}
	}
	
	private var emptyStateView: some View {
		ContentUnavailableView {
			Label {
				Text("All Done For Today")
			} icon: {
				Image(systemName: "star.fill")
					.foregroundStyle(Color.yellow)
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
	}
	
	private var todoListView: some View {
		ForEach(todayTodos) { todo in
			TodoCard(
				todo: todo,
				showDetails: .constant(activeTodo == todo),
				isNewTodo: todo == newlyCreatedTodo
			)
			.onTapGesture {
				withAnimation {
					if activeTodo == todo {
						activeTodo = nil
						newlyCreatedTodo = nil
					} else {
						activeTodo = todo
					}
				}
			}
		}
	}
	
	private var floatingActionButton: some View {
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
	
	// MARK: - Helper Functions
	
	private func addNewTodo() {
		let newTodo = Todo(
			title: "",
			notes: "",
			status: false,
			dueDate: Date.now,
			deadLineDate: Date.now,
			inbox: false
		)
		modelContext.insert(newTodo)
		try? modelContext.save()
		withAnimation {
			activeTodo = newTodo
			newlyCreatedTodo = newTodo
		}
	}
}

#Preview {
	let mockAuthManager = MockAuthManager()
	let container = try! ModelContainer(for: Project.self)
	let syncManager = SyncManager(context: container.mainContext)
	ContentView(authManager: mockAuthManager, syncManager: syncManager)
}
