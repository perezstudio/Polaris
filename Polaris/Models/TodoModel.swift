import SwiftUI
import SwiftData

@Model
class Todo {
	var id: UUID = UUID()
	var title: String = ""
	var notes: String = ""
	var status: Bool = false
	var dueDate: Date?
	var deadLineDate: Date?
	var inbox: Bool = false
	@Relationship(deleteRule: .nullify, inverse: \Project.todos) var project: [Project]? = []
	var created: Date = Date()
	
	init(id: UUID = UUID(), title: String = "", notes: String = "", status: Bool = false, dueDate: Date? = nil, deadLineDate: Date? = nil, inbox: Bool = false, project: [Project]? = []) {
		self.id = id
		self.title = title
		self.notes = notes
		self.status = status
		self.dueDate = dueDate
		self.deadLineDate = deadLineDate
		self.inbox = inbox
		self.project = project
	}
	
	@Transient var dueDateMonth: Int {
		let calendar = Calendar.current
		if dueDate != nil {
			return calendar.component(.month, from: dueDate ?? Date.now)
		} else {
			return 0
		}
	}
	
	@Transient var dueDateDay: Int {
		let calendar = Calendar.current
		if dueDate != nil {
			return calendar.component(.day, from: dueDate ?? Date.now)
		} else {
			return 0
		}
	}
	
	@Transient var dueDateYear: Int {
		let calendar = Calendar.current
		if dueDate != nil {
			return calendar.component(.year, from: dueDate ?? Date.now)
		} else {
			return 0
		}
	}
}
