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
	var id: UUID = UUID()
	var title: String = ""
	var status: Status = Status.InProgress
	var favorite: Bool = false
	var icon: String = "folder"
	var color: ColorPalette = ColorPalette.blue
	@Relationship(deleteRule: .cascade) var todos: [Todo]? = []
	var created: Date = Date.now
	
	init(id: UUID = UUID(), title: String, status: Status = Status.InProgress, favorite: Bool = false, icon: String = "folder", color: ColorPalette = ColorPalette.blue, todos: [Todo] = []) {
		self.id = id
		self.title = title
		self.status = status
		self.favorite = favorite
		self.icon = icon
		self.color = color
		self.todos = todos
	}
}
