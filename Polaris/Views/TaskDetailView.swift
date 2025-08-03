//
//  TaskDetailView.swift
//  Polaris
//
//  Created by Kevin Perez on 8/3/25.
//

import SwiftUI
import SwiftData

struct TaskDetailView: View {
	@Bindable var task: Task
	@Environment(\.modelContext) private var modelContext
	@Environment(GlobalStore.self) private var store
	
	@Query private var projects: [Project]
	@Query private var labels: [TaskLabelModel]
	
	@State private var taskContent: String = ""
	@State private var taskDescription: String = ""
	@State private var selectedProject: Project?
	@State private var selectedPriority: TaskPriority = TaskPriority.none
	@State private var dueDate: Date?
	@State private var hasDueDate = false
	@State private var newSubtask = ""
	@State private var showDeleteConfirmation = false
	
	let isInSheet: Bool
	
	init(task: Task, isInSheet: Bool = false) {
		self.task = task
		self.isInSheet = isInSheet
	}
	
	var body: some View {
		Group {
			if isInSheet {
				NavigationStack {
					taskDetailContent
						.navigationTitle("Task Details")
						#if os(iOS)
						.navigationBarTitleDisplayMode(.inline)
						#endif
						.toolbar {
							sheetToolbarContent
						}
				}
			} else {
				taskDetailContent
					.toolbar {
						inspectorToolbarContent
					}
			}
		}
		.onAppear {
			loadTaskData()
		}
		.confirmationDialog("Delete Task", isPresented: $showDeleteConfirmation) {
			Button("Delete", role: .destructive) {
				deleteTask()
			}
			Button("Cancel", role: .cancel) { }
		} message: {
			Text("Are you sure you want to delete this task? This action cannot be undone.")
		}
	}
	
	@ViewBuilder
	private var taskDetailContent: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 20) {
				// Task completion and content
				VStack(alignment: .leading, spacing: 12) {
					HStack {
						Button {
							toggleCompletion()
						} label: {
							Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
								.foregroundStyle(task.isCompleted ? .green : .gray)
								.font(.title2)
						}
						.buttonStyle(.plain)
						
						TextField("Task name", text: $taskContent)
							.font(.title3)
							.textFieldStyle(.plain)
							.strikethrough(task.isCompleted)
							.foregroundStyle(task.isCompleted ? .secondary : .primary)
					}
					
					TextField("Description", text: $taskDescription, axis: .vertical)
						.textFieldStyle(.roundedBorder)
						.lineLimit(3...8)
				}
				.padding(.horizontal)
				
				// Project and Priority
				VStack(alignment: .leading, spacing: 16) {
					Text("Organization")
						.font(.headline)
						.padding(.horizontal)
					
					VStack(spacing: 12) {
						// Project
						HStack {
							Image(systemName: "folder")
								.foregroundStyle(.purple)
								.frame(width: 24)
							
							Picker("Project", selection: $selectedProject) {
								Text("Inbox").tag(nil as Project?)
								ForEach(projects) { project in
									Label(project.name, systemImage: project.icon)
										.foregroundStyle(project.color.color)
										.tag(project as Project?)
								}
							}
							.pickerStyle(.menu)
						}
						
						// Priority
						HStack {
							Image(systemName: "flag")
								.foregroundStyle(.orange)
								.frame(width: 24)
							
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
							.pickerStyle(.menu)
						}
					}
					.padding(.horizontal)
				}
				
				// Due Date
				VStack(alignment: .leading, spacing: 16) {
					Text("Schedule")
						.font(.headline)
						.padding(.horizontal)
					
					HStack {
						Image(systemName: "calendar")
							.foregroundStyle(.green)
							.frame(width: 24)
						
						Toggle("Due date", isOn: $hasDueDate)
						
						if hasDueDate {
							DatePicker("", selection: Binding(
								get: { dueDate ?? Date() },
								set: { dueDate = $0 }
							), displayedComponents: [.date])
							.labelsHidden()
						}
					}
					.padding(.horizontal)
				}
				
				// Subtasks
				VStack(alignment: .leading, spacing: 16) {
					Text("Subtasks")
						.font(.headline)
						.padding(.horizontal)
					
					VStack(spacing: 8) {
						ForEach(task.subtasks.sorted { $0.position < $1.position }) { subtask in
							SubtaskRowView(subtask: subtask)
						}
						
						// Add subtask
						HStack {
							TextField("Add a subtask", text: $newSubtask)
								.textFieldStyle(.roundedBorder)
								.onSubmit {
									addSubtask()
								}
							
							if !newSubtask.isEmpty {
								Button("Add") {
									addSubtask()
								}
								.buttonStyle(.borderedProminent)
							}
						}
					}
					.padding(.horizontal)
				}
				
				// Labels
				VStack(alignment: .leading, spacing: 16) {
					HStack {
						Text("Labels")
							.font(.headline)
						Spacer()
						Button("Manage Labels") {
							// TODO: Open label management
						}
						.font(.caption)
					}
					.padding(.horizontal)
					
					if !task.labels.isEmpty {
						ScrollView(.horizontal, showsIndicators: false) {
							HStack(spacing: 8) {
								ForEach(task.labels) { label in
									HStack {
										Text(label.name)
											.font(.caption)
										Button {
											removeLabel(label)
										} label: {
											Image(systemName: "xmark.circle.fill")
												.font(.caption)
										}
									}
									.padding(.horizontal, 12)
									.padding(.vertical, 6)
									.background(label.color.color)
									.foregroundStyle(.white)
									.clipShape(Capsule())
								}
							}
							.padding(.horizontal)
						}
					} else {
						Text("No labels")
							.foregroundStyle(.secondary)
							.font(.caption)
							.padding(.horizontal)
					}
				}
				
				// Task metadata
				VStack(alignment: .leading, spacing: 8) {
					Text("Details")
						.font(.headline)
						.padding(.horizontal)
					
					VStack(alignment: .leading, spacing: 4) {
						HStack {
							Text("Created:")
								.foregroundStyle(.secondary)
							Text(task.createdAt, style: .date)
						}
						
						if task.updatedAt != task.createdAt {
							HStack {
								Text("Updated:")
									.foregroundStyle(.secondary)
								Text(task.updatedAt, style: .relative)
							}
						}
						
						if let completedAt = task.completedAt {
							HStack {
								Text("Completed:")
									.foregroundStyle(.secondary)
								Text(completedAt, style: .date)
							}
						}
					}
					.font(.caption)
					.padding(.horizontal)
				}
				
				Spacer(minLength: 100)
			}
		}
	}
	
	@ToolbarContentBuilder
	private var sheetToolbarContent: some ToolbarContent {
		ToolbarItem(placement: .confirmationAction) {
			Button("Done") {
				saveChanges()
				store.closeTaskDetail()
			}
		}
		
		ToolbarItem(placement: .destructiveAction) {
			Button(role: .destructive) {
				showDeleteConfirmation = true
			} label: {
				Image(systemName: "trash")
			}
		}
	}
	
	@ToolbarContentBuilder
	private var inspectorToolbarContent: some ToolbarContent {
		ToolbarItem(placement: .confirmationAction) {
			Button("Save") {
				saveChanges()
			}
		}
		
		ToolbarItem(placement: .destructiveAction) {
			Button(role: .destructive) {
				showDeleteConfirmation = true
			} label: {
				Image(systemName: "trash")
			}
		}
	}
	
	private func loadTaskData() {
		taskContent = task.content
		taskDescription = task.taskDescription
		selectedProject = task.project
		selectedPriority = task.priority
		dueDate = task.dueDate
		hasDueDate = task.dueDate != nil
	}
	
	private func saveChanges() {
		task.content = taskContent.trimmingCharacters(in: .whitespacesAndNewlines)
		task.taskDescription = taskDescription
		task.project = selectedProject
		task.priority = selectedPriority
		task.dueDate = hasDueDate ? dueDate : nil
		task.updatedAt = Date()
		
		try? modelContext.save()
	}
	
	private func toggleCompletion() {
		if task.isCompleted {
			task.uncomplete()
		} else {
			task.complete()
		}
		try? modelContext.save()
	}
	
	private func addSubtask() {
		let trimmed = newSubtask.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty else { return }
		
		let position = task.subtasks.map { $0.position }.max() ?? -1
		let subtask = Subtask(
			content: trimmed,
			position: position + 1,
			parentTask: task
		)
		
		modelContext.insert(subtask)
		try? modelContext.save()
		
		newSubtask = ""
	}
	
	private func removeLabel(_ label: TaskLabelModel) {
		if let taskLabel = task.taskLabels.first(where: { $0.label?.id == label.id }) {
			modelContext.delete(taskLabel)
			try? modelContext.save()
		}
	}
	
	private func deleteTask() {
		modelContext.delete(task)
		try? modelContext.save()
		store.closeTaskDetail()
	}
}

struct SubtaskRowView: View {
	@Bindable var subtask: Subtask
	@Environment(\.modelContext) private var modelContext
	
	var body: some View {
		HStack {
			Button {
				subtask.isCompleted.toggle()
				try? modelContext.save()
			} label: {
				Image(systemName: subtask.isCompleted ? "checkmark.square.fill" : "square")
					.foregroundStyle(subtask.isCompleted ? .green : .gray)
			}
			.buttonStyle(.plain)
			
			Text(subtask.content)
				.strikethrough(subtask.isCompleted)
				.foregroundStyle(subtask.isCompleted ? .secondary : .primary)
			
			Spacer()
			
			Button {
				modelContext.delete(subtask)
				try? modelContext.save()
			} label: {
				Image(systemName: "xmark.circle")
					.foregroundStyle(.secondary)
					.font(.caption)
			}
			.buttonStyle(.plain)
		}
		.padding(.vertical, 2)
	}
}

#Preview {
	TaskDetailView(task: Task(content: "Sample Task"))
		.modelContainer(for: Task.self, inMemory: true)
		.environment(GlobalStore())
}