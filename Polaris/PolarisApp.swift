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
	// Simplified container configuration
	let container: ModelContainer = {
		let schema = Schema([
			Todo.self,
			Project.self,
			SearchItem.self  // Add SearchItem to schema
		])
		let modelConfiguration = ModelConfiguration(
			schema: schema,
			isStoredInMemoryOnly: false
		)
		
		// Handle errors gracefully
		do {
			return try ModelContainer(for: schema, configurations: [modelConfiguration])
		} catch {
			fatalError("Could not initialize ModelContainer: \(error)")
		}
	}()
	
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
		.modelContainer(container)  // Use the configured container
	}
}
