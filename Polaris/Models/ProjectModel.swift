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
	var title: String
	var status: Status
	var favorite: Bool
	var icon: String
	var color: ColorPalette
	@Relationship var todos: [Todo] = []
	var created: Date = Date.now
	
	init(id: UUID = UUID(), title: String, status: Status, favorite: Bool, icon: String, color: ColorPalette, todos: [Todo]=[]) {
		self.id = id
		self.title = title
		self.status = status
		self.favorite = favorite
		self.icon = icon
		self.color = color
		self.todos = todos
	}
}
