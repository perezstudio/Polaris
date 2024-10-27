//
//  TodoModel.swift
//  Polaris
//
//  Created by Kevin Perez on 10/18/24.
//

import SwiftUI
import SwiftData

@Model
class Todo {
	var id: UUID
	var title: String
	var status: Bool
	var notes: String
	var dueDate: Date?
	var deadLine: Date?
	@Relationship(inverse: \Project.todos) var project: Project?
	var inbox: Bool
	
	init(id: UUID = UUID(), title: String, status: Bool, notes: String, dueDate: Date? = nil, deadLine: Date? = nil, project: Project?, inbox: Bool) {
		self.id = id
		self.title = title
		self.status = status
		self.notes = notes
		self.dueDate = dueDate
		self.deadLine = deadLine
		self.project = project
		self.inbox = inbox
	}
}
