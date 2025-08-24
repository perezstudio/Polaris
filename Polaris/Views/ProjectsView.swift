//
//  ProjectsView.swift
//  Polaris
//
//  Created by Kevin Perez on 8/3/25.
//

import SwiftUI
import SwiftData

struct ProjectsView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(GlobalStore.self) private var store
	@Environment(\.dismiss) private var dismiss
	
	@Query(filter: #Predicate<Project> { !$0.isArchived })
	private var activeProjects: [Project]
	
	@Query(filter: #Predicate<Project> { $0.isArchived })
	private var archivedProjects: [Project]
	
	@State private var showCreateProject = false
	@State private var showArchivedProjects = false
	
	var sortedActiveProjects: [Project] {
		activeProjects.sorted { project1, project2 in
			if project1.isFavorite != project2.isFavorite {
				return project1.isFavorite
			}
			return project1.name < project2.name
		}
	}
	
	var body: some View {
		List {
			// Active Projects
			Section {
				if sortedActiveProjects.isEmpty {
					ContentUnavailableView {
						Label("No Projects", systemImage: "folder")
					} description: {
						Text("Create a project to organize your tasks")
					}
				} else {
					ForEach(sortedActiveProjects) { project in
						NavigationLink(destination: ProjectDetailView(project: project)) {
							Label {
								Text(project.name)
							} icon: {
								Image(systemName: project.icon)
									.foregroundStyle(project.color.color)
							}
						}
					}
				}
			}
			
			// Archived Projects
			if !archivedProjects.isEmpty {
				Section {
					DisclosureGroup("Archived Projects (\\(archivedProjects.count))", isExpanded: $showArchivedProjects) {
						ForEach(archivedProjects.sorted { $0.name < $1.name }) { project in
							Label("Test", systemImage: "folder")
						}
					}
				}
			}
		}
		.navigationTitle("Projects")
		.navigationBarTitleDisplayMode(.large)
		.navigationBarBackButtonHidden(true)
		.enableSwipeBack()
		.toolbar {
			ToolbarItemGroup(placement: .bottomBar) {
				Button {
					dismiss()
				} label: {
					Image(systemName: "arrow.left")
				}
				Spacer()
				Button {
					showCreateProject = true
				} label: {
					Image(systemName: "folder.badge.plus")
				}
			}
		}
		.sheet(isPresented: $showCreateProject) {
			CreateProjectView()
				.presentationDetents([.medium])
		}
	}
}

#Preview {
	NavigationStack {
		ProjectsView()
			.modelContainer(for: Project.self, inMemory: true)
			.environment(GlobalStore())
	}
}
