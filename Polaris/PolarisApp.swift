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
	
	@Environment(\.todoInspector) var todoInspector
	@Environment(\.showTodoInspector) var showTodoInspector
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.modelContainer(for: [Project.self, SearchItem.self, Todo.self])
				.inspector(isPresented: showTodoInspector) {
					if let todo = todoInspector.todo {
						TodoDetailsView(todo: todo)
					} else {
						ContentUnavailableView {
							Label {
								Text("Todo Unavailable")
							} icon: {
								Image(systemName: "checkmark.circle")
									.foregroundStyle(Color.gray)
							}
						} description: {
							Text("Looks like something went wrong. Please try again later.")
						} actions: {
							Button {
								todoInspector.showTodoInspector = false
							} label: {
								Label("Close Inspector", systemImage: "xmark.circle.fill")
							}
						}
					}
				}
		}
	}
}
