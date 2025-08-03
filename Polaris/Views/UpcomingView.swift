//
//  UpcomingView.swift
//  Polaris
//
//  Created by Kevin Perez on 8/3/25.
//

import SwiftUI
import SwiftData

struct UpcomingView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(GlobalStore.self) private var store
	
	@Query(filter: #Predicate<Task> { !$0.isCompleted && $0.dueDate != nil })
	private var allTasksWithDates: [Task]
	
	@State private var showAddTask = false
	
	var tomorrowTasks: [Task] {
		allTasksWithDates.filter { $0.isTomorrow }
			.sorted { $0.priority.sortOrder > $1.priority.sortOrder }
	}
	
	var thisWeekTasks: [Task] {
		allTasksWithDates.filter { $0.isThisWeek && !$0.isToday && !$0.isTomorrow && !$0.isOverdue }
			.sorted { $0.dueDate! < $1.dueDate! }
	}
	
	var laterTasks: [Task] {
		allTasksWithDates.filter { !$0.isThisWeek && !$0.isOverdue }
			.sorted { $0.dueDate! < $1.dueDate! }
	}
	
	var body: some View {
		List {
			// Tomorrow Section
			if !tomorrowTasks.isEmpty {
				Section(header: HStack {
					Image(systemName: "calendar.badge.plus")
						.foregroundStyle(.orange)
					Text("Tomorrow")
					Text("\\(tomorrowTasks.count)")
						.foregroundStyle(.secondary)
						.font(.caption)
				}) {
					ForEach(tomorrowTasks) { task in
						TaskRowView(task: task)
					}
				}
			}
			
			// This Week Section
			if !thisWeekTasks.isEmpty {
				Section(header: HStack {
					Image(systemName: "calendar")
						.foregroundStyle(.blue)
					Text("This Week")
					Text("\\(thisWeekTasks.count)")
						.foregroundStyle(.secondary)
						.font(.caption)
				}) {
					ForEach(thisWeekTasks) { task in
						TaskRowView(task: task)
					}
				}
			}
			
			// Later Section
			if !laterTasks.isEmpty {
				Section(header: HStack {
					Image(systemName: "calendar.badge.clock")
						.foregroundStyle(.purple)
					Text("Later")
					Text("\\(laterTasks.count)")
						.foregroundStyle(.secondary)
						.font(.caption)
				}) {
					ForEach(laterTasks) { task in
						TaskRowView(task: task)
					}
				}
			}
			
			// Empty State
			if tomorrowTasks.isEmpty && thisWeekTasks.isEmpty && laterTasks.isEmpty {
				Section {
					ContentUnavailableView {
						Label("No upcoming tasks", systemImage: "calendar.badge.checkmark")
					} description: {
						Text("Tasks with due dates will appear here")
					}
				}
			}
		}
		.navigationTitle("Upcoming")
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button {
					showAddTask = true
				} label: {
					Image(systemName: "plus")
				}
			}
		}
		.sheet(isPresented: $showAddTask) {
			AddTaskView()
				.presentationDetents([.medium])
		}
	}
}

#Preview {
	NavigationStack {
		UpcomingView()
			.modelContainer(for: Task.self, inMemory: true)
			.environment(GlobalStore())
	}
}