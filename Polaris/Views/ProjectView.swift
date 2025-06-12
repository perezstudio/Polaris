//
//  ProjectView.swift
//  Polaris
//
//  Created by Kevin Perez on 4/24/25.
//

import SwiftUI
import SwiftData

struct ProjectView: View {
	
	@Bindable var project: Project
	
	var body: some View {
		NavigationStack {
			List {
				if !project.todos.isEmpty {
					ForEach(project.sections) { section in
						SwiftUI.Section(header: Text(section.title)) {
							ForEach(section.todos) { todo in
								Text(todo.title)
							}
						}
					}
				} else {
					ContentUnavailableView(
						"No Todos Left",
						systemImage: "checkmark.circle",
						description: Text("Great Job! You're on a roll!")
					)
				}
			}
			.navigationTitle(project.title)
			#if os(iOS)
			.navigationBarTitleDisplayMode(.large)
			#endif
		}
	}
}

#Preview {
	
	let newProject = Project(title: "Hello World", icon: "rectangle.stack.fill.badge.plus", color: ProjectColor.blue)
	
	ProjectView(project: newProject)
}
