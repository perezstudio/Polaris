//
//  Models.swift
//  Polaris
//
//  Created by Kevin Perez on 4/25/25.
//

import SwiftUI
import SwiftData
import Foundation

@Model
class Project {
	var id: UUID
	var name: String
	var color: ProjectColor
	var icon: String
	var isArchived: Bool = false
	var isFavorite: Bool = false
	
	@Relationship(deleteRule: .cascade, inverse: \Task.project)
	var tasks: [Task] = []
	
	var createdAt: Date = Date()
	
	init(id: UUID = UUID(), name: String, color: ProjectColor = ProjectColor.blue, icon: String = "folder") {
		self.id = id
		self.name = name
		self.color = color
		self.icon = icon
	}
	
	var incompleteTasks: [Task] {
		tasks.filter { !$0.isCompleted }
	}
	
	var completedTasks: [Task] {
		tasks.filter { $0.isCompleted }
	}
}

@Model
class Task {
	var id: UUID
	var content: String
	var taskDescription: String = ""
	var isCompleted: Bool = false
	var priority: TaskPriority = TaskPriority.none
	var dueDate: Date?
	var completedAt: Date?
	var position: Int = 0
	
	@Relationship(deleteRule: .nullify)
	var project: Project?
	
	@Relationship(deleteRule: .cascade, inverse: \Subtask.parentTask)
	var subtasks: [Subtask] = []
	
	@Relationship(deleteRule: .cascade, inverse: \TaskLabel.task)
	var taskLabels: [TaskLabel] = []
	
	var createdAt: Date = Date()
	var updatedAt: Date = Date()
	
	init(id: UUID = UUID(),
		 content: String,
		 taskDescription: String = "",
		 priority: TaskPriority = TaskPriority.none,
		 dueDate: Date? = nil,
		 project: Project? = nil) {
		self.id = id
		self.content = content
		self.taskDescription = taskDescription
		self.priority = priority
		self.dueDate = dueDate
		self.project = project
	}
	
	// Computed properties for date checking
	var isOverdue: Bool {
		guard let dueDate = dueDate, !isCompleted else { return false }
		return dueDate < Calendar.current.startOfDay(for: Date())
	}
	
	var isToday: Bool {
		guard let dueDate = dueDate else { return false }
		return Calendar.current.isDateInToday(dueDate)
	}
	
	var isTomorrow: Bool {
		guard let dueDate = dueDate else { return false }
		return Calendar.current.isDateInTomorrow(dueDate)
	}
	
	var isThisWeek: Bool {
		guard let dueDate = dueDate else { return false }
		let calendar = Calendar.current
		return calendar.isDate(dueDate, equalTo: Date(), toGranularity: .weekOfYear)
	}
	
	var labels: [TaskLabelModel] {
		taskLabels.compactMap { $0.label }
	}
	
	func complete() {
		isCompleted = true
		completedAt = Date()
		updatedAt = Date()
	}
	
	func uncomplete() {
		isCompleted = false
		completedAt = nil
		updatedAt = Date()
	}
}

@Model
class Subtask {
	var id: UUID
	var content: String
	var isCompleted: Bool = false
	var position: Int = 0
	
	@Relationship(deleteRule: .nullify)
	var parentTask: Task?
	
	var createdAt: Date = Date()
	
	init(id: UUID = UUID(), content: String, isCompleted: Bool = false, position: Int = 0, parentTask: Task? = nil) {
		self.id = id
		self.content = content
		self.isCompleted = isCompleted
		self.position = position
		self.parentTask = parentTask
	}
}

@Model
class TaskLabelModel {
	var id: UUID
	var name: String
	var color: ProjectColor
	var isFavorite: Bool = false
	
	@Relationship(deleteRule: .cascade, inverse: \TaskLabel.label)
	var taskLabels: [TaskLabel] = []
	
	var createdAt: Date = Date()
	
	init(id: UUID = UUID(), name: String, color: ProjectColor) {
		self.id = id
		self.name = name
		self.color = color
	}
	
	var tasks: [Task] {
		taskLabels.compactMap { $0.task }
	}
}

@Model
class TaskLabel {
	var id: UUID
	
	@Relationship(deleteRule: .nullify)
	var task: Task?
	
	@Relationship(deleteRule: .nullify)
	var label: TaskLabelModel?
	
	var createdAt: Date = Date()
	
	init(id: UUID = UUID(), task: Task? = nil, label: TaskLabelModel? = nil) {
		self.id = id
		self.task = task
		self.label = label
	}
}

struct IconCategory: Identifiable {
	let id = UUID()
	let name: String
	let symbols: [String] // SF Symbol names
}

let iconCategories: [IconCategory] = [
	IconCategory(name: "Communication", symbols: [
		"microphone",
		"microphone.fill",
		"microphone.circle",
		"microphone.cicle.fill",
		"microphone.square",
		"microphone.square.fill",
		"microphone.slash",
		"microphone.slash.fill",
		"microphone.slash.circle",
		"microphone.slash.circle.fill",
		"microphone.badge.plus",
		"microphone.badge.plus.fill",
		"microphone.badge.xmark",
		"microphone.badge.xmark.fill",
		"microphone.badge.ellipsis",
		"microphone.badge.ellipsis.fill",
		"microphone.and.signal.meter",
		"microphone.and.signal.meter.fill",
		"line.diagonal",
		"line.diagonal.arrow",
		"message",
		"message.fill",
		"message.circle",
		"message.circle.fill",
		"message.badge",
		"message.badge.filled.fill",
		"message.badge.circle",
		"message.badge.circle.fill",
		"message.badge.fill",
		"message.badge.waveform",
		"message.badge.waveform.fill"
	]),
	IconCategory(name: "Objects", symbols: [
		"folder",
		"doc",
		"tray",
		"paperclip",
		"rectangle.stack.fill"
	]),
	IconCategory(name: "People", symbols: [
		"person",
		"person.2",
		"person.crop.circle"
	]),
	IconCategory(name: "Communication", symbols: [
		"bubble.left",
		"envelope",
		"phone"
	])
]
