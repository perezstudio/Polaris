import SwiftUI
import SwiftData

@Model
class Todo {
	var id: UUID
	var title: String
	var notes: String
	var status: Bool
	var dueDate: Date?
	var deadLineDate: Date?
	var inbox: Bool
	@Relationship(deleteRule: .nullify, inverse: \Project.todos) var project: [Project] = []
	var created: Date = Date()
	
	init(id: UUID = UUID(), title: String, notes: String, status: Bool, dueDate: Date?, deadLineDate: Date?, inbox: Bool, project: [Project] = []) {
		self.id = id
		self.title = title
		self.notes = notes
		self.status = status
		self.dueDate = dueDate
		self.deadLineDate = deadLineDate
		self.inbox = inbox
		self.project = project
	}
}
