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
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.modelContainer(for: [Project.self, SearchItem.self, Todo.self, ])
		}
	}
}
