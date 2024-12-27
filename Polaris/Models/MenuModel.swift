//
//  MenuModel.swift
//  Polaris
//
//  Created by Kevin Perez on 12/23/24.
//

import SwiftUI

struct Section {
	var id: UUID
	var title: String
	var items: [MenuOption]
}

struct MenuOption {
	var id: UUID
	var string: String
	var icon: String
	var color: Color
}

var menuSections: [Section] = [Section(id: UUID(), title: "", items: [MenuOption(id: UUID(), string: "Inbox", icon: "tray.fill", color: Color.blue)]), Section(id: UUID(), title: "", items: [MenuOption(id: UUID(), string: "Today", icon: "star.fill", color: Color.yellow)])]
