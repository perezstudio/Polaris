//
//  MenuModel.swift
//  Polaris
//
//  Created by Kevin Perez on 4/25/25.
//

import SwiftUI
import SwiftData

// Menu item structure
struct MenuItem: Identifiable {
	var id = UUID()
	var title: String
	var icon: String
	var color: Color = .primary
	var destination: AnyView
	
	init(title: String, icon: String, color: Color = .primary, destination: some View) {
		self.title = title
		self.icon = icon
		self.color = color
		self.destination = AnyView(destination)
	}
}

// Section structure
struct MenuSection: Identifiable {
	var id = UUID()
	var title: String?
	var items: [MenuItem]
}
