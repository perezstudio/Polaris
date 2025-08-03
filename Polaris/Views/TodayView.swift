//
//  TodayView.swift
//  Polaris
//
//  Created by Kevin Perez on 8/3/25.
//

import SwiftUI
import SwiftData

struct TodayView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(GlobalStore.self) private var store
	
	@Query(filter: #Predicate<Task> { !$0.isCompleted && $0.dueDate != nil })
	private var allTasksWithDates: [Task]
	
	@Query(filter: #Predicate<Task> { !$0.isCompleted && $0.dueDate == nil })
	private var tasksWithoutDates: [Task]
	
	@State private var showAddTask = false
	@State private var newTaskContent = ""
	
	var overdueTasks: [Task] {
		allTasksWithDates.filter { $0.isOverdue }
			.sorted { $0.dueDate! < $1.dueDate! }
	}
	
	var todayTasks: [Task] {
		allTasksWithDates.filter { $0.isToday }
			.sorted { $0.priority.sortOrder > $1.priority.sortOrder }
	}
	
	var body: some View {
		List {
			// Quick Add Task
			Section {
				HStack {
					TextField("Add a task", text: $newTaskContent)
						.textFieldStyle(.plain)
						.onSubmit {
							addQuickTask()
						}
					
					if !newTaskContent.isEmpty {
						Button("Add") {
							addQuickTask()
						}
						.buttonStyle(.borderedProminent)
					}
				}
				.padding(.vertical, 4)
			}
			
			// Overdue Section
			if !overdueTasks.isEmpty {
				Section(header: HStack {
					Image(systemName: "exclamationmark.triangle.fill")
						.foregroundStyle(.red)
					Text("Overdue")
						.foregroundStyle(.red)
					Text("\\(overdueTasks.count)")
						.foregroundStyle(.secondary)
						.font(.caption)
				}) {
					ForEach(overdueTasks) { task in
						TaskRowView(task: task)
					}
				}
			}
			
			// Today Section
			Section(header: HStack {
				Image(systemName: "calendar")
					.foregroundStyle(.green)
				Text("Today")
				Text("\\(todayTasks.count)")
					.foregroundStyle(.secondary)
					.font(.caption)
			}) {
				if todayTasks.isEmpty {
					Text("No tasks for today")
						.foregroundStyle(.secondary)
						.italic()
				} else {
					ForEach(todayTasks) { task in
						TaskRowView(task: task)
					}
				}
			}
		}
		.navigationTitle("Today")
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
	
	private func addQuickTask() {
		let trimmedContent = newTaskContent.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmedContent.isEmpty else { return }
		
		let task = Task(content: trimmedContent, dueDate: Date())
		modelContext.insert(task)
		
		do {
			try modelContext.save()
			newTaskContent = ""
		} catch {
			print("Failed to add task: \\(error)")
		}
	}
}

struct TaskRowView: View {
	@Bindable var task: Task
	@Environment(\.modelContext) private var modelContext
	@Environment(GlobalStore.self) private var store
	
	var body: some View {
		HStack(spacing: 12) {
			// Completion Button
			Button {
				toggleCompletion()
			} label: {
				Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
					.foregroundStyle(task.isCompleted ? .green : .gray)
					.font(.title3)
			}
			.buttonStyle(.plain)
			
			// Task Content
			VStack(alignment: .leading, spacing: 4) {
				HStack {
					Text(task.content)
						.strikethrough(task.isCompleted)
						.foregroundStyle(task.isCompleted ? .secondary : .primary)
					
					Spacer()
					
					// Priority Flag
					if task.priority != .none {
						Image(systemName: task.priority.icon)
							.foregroundStyle(task.priority.color)
							.font(.caption)
					}
				}
				
				// Task Metadata
				HStack(spacing: 12) {
					// Project
					if let project = task.project {
						Label(project.name, systemImage: project.icon)
							.font(.caption)
							.foregroundStyle(project.color.color)
					}
					
					// Due Date
					if let dueDate = task.dueDate {
						Label {
							if task.isOverdue {
								Text(dueDate, style: .date)
									.foregroundStyle(.red)
							} else if task.isToday {
								Text("Today")
									.foregroundStyle(.green)
							} else {
								Text(dueDate, style: .date)
									.foregroundStyle(.secondary)
							}
						} icon: {
							Image(systemName: "calendar")
						}
						.font(.caption)
					}
					
					// Labels
					if !task.labels.isEmpty {
						HStack(spacing: 4) {
							ForEach(task.labels.prefix(2)) { label in
								Text(label.name)
									.font(.caption2)
									.padding(.horizontal, 6)
									.padding(.vertical, 2)
									.background(label.color.color.opacity(0.2))
									.foregroundStyle(label.color.color)
									.clipShape(Capsule())
							}
							
							if task.labels.count > 2 {
								Text("+\\(task.labels.count - 2)")
									.font(.caption2)
									.foregroundStyle(.secondary)
							}
						}
					}
					
					Spacer()
				}
			}
		}
		.contentShape(Rectangle())
		.onTapGesture {
			store.selectTask(task)
		}
	}
	
	private func toggleCompletion() {
		if task.isCompleted {
			task.uncomplete()
		} else {
			task.complete()
		}
		
		try? modelContext.save()
	}
}

#Preview {
	NavigationStack {
		TodayView()
			.modelContainer(for: Task.self, inMemory: true)
			.environment(GlobalStore())
	}
}