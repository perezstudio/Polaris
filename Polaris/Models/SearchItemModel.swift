//
//  SearchItemModel.swift
//  Polaris
//
//  Created by Kevin Perez on 12/28/24.
//

import SwiftUI
import SwiftData

@Model
class SearchItem {
	// Remove persistence attributes with default values
	var id: UUID = UUID()
	var text: String = ""
	var created: Date = Date()
	
	init(id: UUID = UUID(), text: String, created: Date = Date()) {
		self.id = id
		self.text = text
		self.created = created
	}
}
