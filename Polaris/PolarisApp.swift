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
				.modelContainer(for: [Project.self, Task.self, Subtask.self, TaskLabelModel.self, TaskLabel.self])
				.environment(globalStore)
		}
	}
}
