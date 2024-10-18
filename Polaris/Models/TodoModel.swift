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
	var notes: String
	var dueDate: Date?
	var deadLine: Date?
	
	init(id: UUID = UUID(), title: String, notes: String, dueDate: Date? = nil, deadLine: Date? = nil) {
		self.id = id
		self.title = title
		self.notes = notes
		self.dueDate = dueDate
		self.deadLine = deadLine
	}
}
