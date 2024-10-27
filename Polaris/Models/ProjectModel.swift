//
//  ProjectModel.swift
//  Polaris
//
//  Created by Kevin Perez on 10/18/24.
//

import SwiftUI
import SwiftData

@Model
class Project {
	var id: UUID
	var name: String
	var notes: String
	var dueDate: Date?
	var deadLine: Date?
	var status: Status
	var icon: String
	var color: ProjectColors
	@Relationship(deleteRule: .cascade) var todos: [Todo] = []
	
	init(id: UUID = UUID(), name: String, notes: String, dueDate: Date? = nil, deadLine: Date? = nil, status: Status, icon: String, color: ProjectColors, todos: [Todo] = []) {
		self.id = id
		self.name = name
		self.notes = notes
		self.dueDate = dueDate
		self.deadLine = deadLine
		self.status = status
		self.icon = icon
		self.color = color
		self.todos = todos
	}
}
