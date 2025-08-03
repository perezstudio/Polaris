//
//  AddTaskView.swift
//  Polaris
//
//  Created by Kevin Perez on 8/3/25.
//

import SwiftUI
import SwiftData

struct AddTaskView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	@Query private var projects: [Project]
	
	@State private var taskContent = ""
	@State private var taskDescription = ""
	@State private var selectedProject: Project?
	@State private var selectedPriority: TaskPriority = TaskPriority.none
	@State private var dueDate: Date?
	@State private var hasDueDate = false
	
	@FocusState private var isFocused: Bool
	
	// Optional preselected project
	private let preselectedProject: Project?
	
	init(preselectedProject: Project? = nil) {
		self.preselectedProject = preselectedProject
	}
	
	var body: some View {
		NavigationStack {
			Form {
				Section {
					TextField("Task name", text: $taskContent)
						.focused($isFocused)
					
					TextField("Description", text: $taskDescription, axis: .vertical)
						.lineLimit(2...4)
				}
				
				Section("Organization") {
					// Project Picker
					Picker("Project", selection: $selectedProject) {
						Text("Inbox").tag(nil as Project?)
						ForEach(projects) { project in
							Label(project.name, systemImage: project.icon)
								.foregroundStyle(project.color.color)
								.tag(project as Project?)
						}
					}
					
					// Priority Picker
					Picker("Priority", selection: $selectedPriority) {
						ForEach(TaskPriority.allCases, id: \.self) { priority in
							HStack {
								Image(systemName: priority.icon)
									.foregroundStyle(priority.color)
								Text(priority.name)
							}
							.tag(priority)
						}
					}
				}
				
				Section("Schedule") {
					Toggle("Due date", isOn: $hasDueDate)
					
					if hasDueDate {
						DatePicker("Due date", selection: Binding(
							get: { dueDate ?? Date() },
							set: { dueDate = $0 }
						), displayedComponents: [.date])
					}
				}
			}
			.navigationTitle("Add Task")
			#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
			#endif
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") {
						dismiss()
					}
				}
				
				ToolbarItem(placement: .confirmationAction) {
					Button("Add") {
						addTask()
					}
					.disabled(taskContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
				}
			}
			.onAppear {
				isFocused = true
				if let preselected = preselectedProject {
					selectedProject = preselected
				}
			}
		}
	}
	
	private func addTask() {
		let trimmedContent = taskContent.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmedContent.isEmpty else { return }
		
		let task = Task(
			content: trimmedContent,
			taskDescription: taskDescription,
			priority: selectedPriority,
			dueDate: hasDueDate ? dueDate : nil,
			project: selectedProject
		)
		
		modelContext.insert(task)
		
		do {
			try modelContext.save()
			dismiss()
		} catch {
			print("Failed to add task: \\(error)")
		}
	}
}

#Preview {
	AddTaskView()
		.modelContainer(for: Task.self, inMemory: true)
}