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
	
	var container: ModelContainer = {
		let schema = Schema([
			Todo.self,
			Project.self,
			SearchItem.self
		])
		let modelConfiguration = ModelConfiguration(
			schema: schema,
			isStoredInMemoryOnly: false
		)
		
		do {
			return try ModelContainer(for: schema)
		} catch {
			fatalError("Failed to initialize model container: \(error)")
		}
	}()
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.modelContainer(container) // Inject ModelContainer here
				.ignoresSafeArea(.keyboard, edges: .bottom)
		}
	}
}
