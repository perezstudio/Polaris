//
//  PolarisApp.swift
//  Polaris
//
//  Created by Kevin Perez on 10/18/24.
//

import SwiftUI
import SwiftData

@main
struct PolarisApp: App {
	
	@State private var globalStore = GlobalStore()
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.modelContainer(for: [Project.self, Section.self, Todo.self, ChecklistItem.self])
				.environment(globalStore)
		}
	}
}
