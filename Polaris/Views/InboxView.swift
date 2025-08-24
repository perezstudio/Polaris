//
//  InboxView.swift
//  Polaris
//
//  Created by Kevin Perez on 8/3/25.
//

import SwiftUI
import SwiftData

struct InboxView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(GlobalStore.self) private var store
	@Environment(\.dismiss) private var dismiss
	
	@Query(filter: #Predicate<Task> { !$0.isCompleted && $0.project == nil })
	private var inboxTasks: [Task]
	
	@State private var newTaskContent = ""
	@State private var showAddTask = false
	
	var sortedTasks: [Task] {
		inboxTasks.sorted { task1, task2 in
			// Sort by priority first, then by creation date
			if task1.priority != task2.priority {
				return task1.priority.sortOrder > task2.priority.sortOrder
			}
			return task1.createdAt > task2.createdAt
		}
	}
	
	var body: some View {
		List {
			// Tasks Section
			Section {
				if sortedTasks.isEmpty {
					ContentUnavailableView {
						Label("Inbox is empty", systemImage: "tray")
					} description: {
						Text("Add tasks here to organize them later")
					}
				} else {
					ForEach(sortedTasks) { task in
						TaskRowView(task: task)
					}
					.onDelete(perform: deleteTasks)
				}
			}
		}
		.navigationTitle("Inbox")
		.navigationBarTitleDisplayMode(.large)
		.navigationBarBackButtonHidden(true)
		.enableSwipeBack()
		.toolbar {
			ToolbarItemGroup(placement: .bottomBar) {
				Button {
					dismiss()
				} label: {
					Image(systemName: "arrow.left")
				}
				Spacer()
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
	
	private func addQuickTask() {
		let trimmedContent = newTaskContent.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmedContent.isEmpty else { return }
		
		let task = Task(content: trimmedContent)
		modelContext.insert(task)
		
		do {
			try modelContext.save()
			newTaskContent = ""
		} catch {
			print("Failed to add task: \\(error)")
		}
	}
	
	private func deleteTasks(offsets: IndexSet) {
		withAnimation {
			for index in offsets {
				modelContext.delete(sortedTasks[index])
			}
			try? modelContext.save()
		}
	}
}

#Preview {
	NavigationStack {
		InboxView()
			.modelContainer(for: Task.self, inMemory: true)
			.environment(GlobalStore())
	}
}
