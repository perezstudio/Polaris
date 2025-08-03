//
//  ProjectDetailView.swift
//  Polaris
//
//  Created by Kevin Perez on 8/3/25.
//

import SwiftUI
import SwiftData

struct ProjectDetailView: View {
	@Bindable var project: Project
	@Environment(\.modelContext) private var modelContext
	@Environment(GlobalStore.self) private var store
	
	@State private var newTaskContent = ""
	@State private var showAddTask = false
	@State private var showCompleted = false
	
	var sortedIncompleteTasks: [Task] {
		project.incompleteTasks.sorted { task1, task2 in
			// Sort by priority first, then by due date, then by creation date
			if task1.priority != task2.priority {
				return task1.priority.sortOrder > task2.priority.sortOrder
			}
			
			// Handle due dates
			switch (task1.dueDate, task2.dueDate) {
			case (let date1?, let date2?):
				return date1 < date2
			case (nil, _):
				return false
			case (_, nil):
				return true
			}
		}
	}
	
	var sortedCompletedTasks: [Task] {
		project.completedTasks.sorted { $0.completedAt! > $1.completedAt! }
	}
	
	var body: some View {
		List {
			// Quick Add Task
			Section {
				HStack {
					TextField("Add a task to \\(project.name)", text: $newTaskContent)
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
			
			// Incomplete Tasks
			Section {
				if sortedIncompleteTasks.isEmpty {
					Text("No tasks yet")
						.foregroundStyle(.secondary)
						.italic()
				} else {
					ForEach(sortedIncompleteTasks) { task in
						TaskRowView(task: task)
					}
					.onDelete(perform: deleteIncompleteTasks)
				}
			} header: {
				HStack {
					Text("Tasks")
					Spacer()
					Text("\\(sortedIncompleteTasks.count)")
						.foregroundStyle(.secondary)
						.font(.caption)
				}
			}
			
			// Completed Tasks (collapsible)
			if !sortedCompletedTasks.isEmpty {
				Section {
					DisclosureGroup("Completed (\\(sortedCompletedTasks.count))", isExpanded: $showCompleted) {
						ForEach(sortedCompletedTasks) { task in
							TaskRowView(task: task)
								.opacity(0.6)
						}
						.onDelete(perform: deleteCompletedTasks)
					}
				}
			}
		}
		.navigationTitle(project.name)
		#if os(iOS)
		.navigationBarTitleDisplayMode(.large)
		#endif
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button {
					showAddTask = true
				} label: {
					Image(systemName: "plus")
				}
			}
			
			ToolbarItem(placement: .secondaryAction) {
				Menu {
					Button {
						project.isFavorite.toggle()
						try? modelContext.save()
					} label: {
						Label(project.isFavorite ? "Remove from Favorites" : "Add to Favorites",
							  systemImage: project.isFavorite ? "star.slash" : "star")
					}
					
					Button {
						project.isArchived.toggle()
						try? modelContext.save()
					} label: {
						Label("Archive Project", systemImage: "archivebox")
					}
				} label: {
					Image(systemName: "ellipsis.circle")
				}
			}
		}
		.sheet(isPresented: $showAddTask) {
			AddTaskView(preselectedProject: project)
				.presentationDetents([.medium])
		}
	}
	
	private func addQuickTask() {
		let trimmedContent = newTaskContent.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmedContent.isEmpty else { return }
		
		let task = Task(content: trimmedContent, project: project)
		modelContext.insert(task)
		
		do {
			try modelContext.save()
			newTaskContent = ""
		} catch {
			print("Failed to add task: \\(error)")
		}
	}
	
	private func deleteIncompleteTasks(offsets: IndexSet) {
		withAnimation {
			for index in offsets {
				modelContext.delete(sortedIncompleteTasks[index])
			}
			try? modelContext.save()
		}
	}
	
	private func deleteCompletedTasks(offsets: IndexSet) {
		withAnimation {
			for index in offsets {
				modelContext.delete(sortedCompletedTasks[index])
			}
			try? modelContext.save()
		}
	}
}

// Extension removed - AddTaskView will be updated to handle preselected projects differently

#Preview {
	NavigationStack {
		ProjectDetailView(project: Project(name: "Sample Project"))
			.modelContainer(for: Project.self, inMemory: true)
			.environment(GlobalStore())
	}
}