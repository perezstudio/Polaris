//
//  Models.swift
//  Polaris
//
//  Created by Kevin Perez on 4/25/25.
//

import SwiftUI
import SwiftData

@Model
class Project {
	var id: UUID
	var title: String
	var icon: String
	var color: ProjectColor
	
	@Relationship(deleteRule: .cascade, inverse: \Section.project)
	var sections: [Section] = []
	
	@Relationship(deleteRule: .cascade, inverse: \Todo.project)
	var todos: [Todo] = []
	
	var createdAt: Date = Date()
	
	init(id: UUID = UUID(), title: String, icon: String, color: ProjectColor) {
		self.id = id
		self.title = title
		self.icon = icon
		self.color = color
	}
}

@Model
class Section {
	var id: UUID
	var title: String
	
	@Relationship(deleteRule: .nullify)
	var project: Project?
	
	@Relationship(deleteRule: .cascade, inverse: \Todo.section)
	var todos: [Todo] = []
	
	var createdAt: Date = Date()
	
	init(id: UUID = UUID(), title: String, project: Project? = nil) {
		self.id = id
		self.title = title
		self.project = project
	}
}

@Model
class Todo {
	var id: UUID
	var title: String
	var descriptionText: Data?
	var isCompleted: Bool = false
	var isInbox: Bool = true  // New property - defaults to true
	var dueDate: Date?
	var deadline: Date?

	@Relationship(deleteRule: .nullify)
	var project: Project?

	@Relationship(deleteRule: .nullify)
	var section: Section?

	@Relationship(deleteRule: .cascade, inverse: \ChecklistItem.todo)
	var checklistItems: [ChecklistItem] = []

	var createdAt: Date = Date()

	init(id: UUID = UUID(),
		title: String,
		 descriptionText: Data? = nil,
		 isCompleted: Bool = false,
		 isInbox: Bool = true,  // Add to initializer
		 dueDate: Date? = nil,
		 deadline: Date? = nil,
		 project: Project? = nil,
		 section: Section? = nil) {
		self.id = id
		self.title = title
		self.descriptionText = descriptionText
		self.isCompleted = isCompleted
		self.isInbox = isInbox
		self.dueDate = dueDate
		self.deadline = deadline
		self.project = project
		self.section = section
		
		// If a project or section is set, it's no longer in the inbox
		if project != nil || section != nil {
			self.isInbox = false
		}
	}
	
	// Computed property to check if a todo belongs in inbox
	var belongsInInbox: Bool {
		return isInbox || (project == nil && section == nil)
	}
	
	var isToday: Bool {
		let calendar = Calendar.current
		let today = calendar.startOfDay(for: Date())
		let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
		
		// Check if dueDate is today or earlier
		if let dueDate = dueDate {
			let dueDateStart = calendar.startOfDay(for: dueDate)
			if dueDateStart < tomorrow {
				return true
			}
		}
		
		// Check if deadline is today or earlier
		if let deadline = deadline {
			let deadlineStart = calendar.startOfDay(for: deadline)
			if deadlineStart < tomorrow {
				return true
			}
		}
		
		return false
	}
	
	var dueDateYear: Int {
		guard let dueDate = dueDate else { return 0 }
		return Calendar.current.component(.year, from: dueDate)
	}
	
	/// Returns the month component of the due date (1-12)
	var dueDateMonth: Int {
		guard let dueDate = dueDate else { return 0 }
		return Calendar.current.component(.month, from: dueDate)
	}
	
	/// Returns the day component of the due date (1-31)
	var dueDateDay: Int {
		guard let dueDate = dueDate else { return 0 }
		return Calendar.current.component(.day, from: dueDate)
	}
	
	// MARK: - Deadline Components
	
	/// Returns the year component of the deadline
	var deadlineYear: Int {
		guard let deadline = deadline else { return 0 }
		return Calendar.current.component(.year, from: deadline)
	}
	
	/// Returns the month component of the deadline (1-12)
	var deadlineMonth: Int {
		guard let deadline = deadline else { return 0 }
		return Calendar.current.component(.month, from: deadline)
	}
	
	/// Returns the day component of the deadline (1-31)
	var deadlineDay: Int {
		guard let deadline = deadline else { return 0 }
		return Calendar.current.component(.day, from: deadline)
	}
	
	var attributedDescription: NSAttributedString {
		get {
			guard let data = descriptionText else {
				return NSAttributedString(string: "")
			}
			return (try? NSAttributedString(data: data, options: [
				.documentType: NSAttributedString.DocumentType.rtf
			], documentAttributes: nil)) ?? NSAttributedString(string: "")
		}
		set {
			descriptionText = try? newValue.data(from: NSRange(location: 0, length: newValue.length), documentAttributes: [
				.documentType: NSAttributedString.DocumentType.rtf
			])
		}
	}
}

@Model
class ChecklistItem {
	var id: UUID
	var title: String
	var isCompleted: Bool = false
	
	@Relationship(deleteRule: .nullify)
	var todo: Todo?
	
	var createdAt: Date = Date()
	
	init(id: UUID = UUID(), title: String, isCompleted: Bool = false, todo: Todo? = nil) {
		self.id = id
		self.title = title
		self.isCompleted = isCompleted
		self.todo = todo
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
