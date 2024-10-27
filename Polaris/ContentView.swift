//
//  ContentView.swift
//  Polaris
//
//  Created by Kevin Perez on 10/18/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
	
    @Environment(\.modelContext) private var modelContext
	@Query private var projects: [Project]
	@State var selectedProject: Project? = nil

    var body: some View {
        NavigationSplitView {
			MainMenuView(selectedProject: $selectedProject)
        } detail: {
			List {
				ContentUnavailableView {
					Label("Select A Project or Filter", systemImage: "rectangle.stack")
				} description: {
					Text("Select a Project or Filter View from the sidebar.")
				}
			}
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Project.self, inMemory: true)
}
