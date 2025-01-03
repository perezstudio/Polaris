//
//  ContentView.swift
//  Polaris
//
//  Created by Kevin Perez on 10/18/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
	
    @Environment(\.modelContext) private var modelContext
	@ObservedObject var authManager: AuthManager
	@Query(filter: #Predicate<Todo> { todo in
		todo.dueDate != nil && todo.status == false
	}, sort: \Todo.created) var todos: [Todo]
	@Query(filter: #Predicate<Todo> { todo in
		todo.inbox == true && todo.status == false
		}, sort: \Todo.created, order: .forward) var inboxTodos: [Todo]
	@State var selectedProject: Project? = nil
	
	var syncManager: SyncManager
	
	private var todayTodos: [Todo] {
		todos.filter { todo in
			guard let dueDate = todo.dueDate else { return false }
			return Calendar.current.isDateInToday(dueDate)
		}
	}

    var body: some View {
		TabView {
			if (todayTodos.isEmpty) {
				Tab("Today", systemImage: "star.fill") {
					TodayView()
				}
			} else {
				Tab("Today", systemImage: "star.fill") {
					TodayView()
				}
				.badge(todayTodos.count)
			}
			
			Tab("Upcoming", systemImage: "calendar") {
				UpcomingView()
			}
			if (inboxTodos.isEmpty) {
				Tab("Inbox", systemImage: "tray.fill") {
					InboxView()
				}
			} else {
				Tab("Inbox", systemImage: "tray.fill") {
					InboxView()
				}
				.badge(inboxTodos.count)
			}
			Tab("Search", systemImage: "magnifyingglass") {
				SearchView()
			}
			Tab("Browse", systemImage: "square.stack.fill") {
				BrowseView(authManager: authManager, syncManager: syncManager)
			}
		}
		.tabViewStyle(.sidebarAdaptable)
    }
}

#Preview {
	let mockAuthManager = MockAuthManager()
	let container = try! ModelContainer(for: Project.self)
	let syncManager = SyncManager(context: container.mainContext)
	ContentView(authManager: mockAuthManager, syncManager: syncManager)
        .modelContainer(for: Project.self, inMemory: true)
}
