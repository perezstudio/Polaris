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
						ProjectRowView(project: project)
					}
				}
			} header: {
				HStack {
					Text("Projects")
					Spacer()
					Text("\\(sortedActiveProjects.count)")
						.foregroundStyle(.secondary)
						.font(.caption)
				}
			}
			
			// Archived Projects
			if !archivedProjects.isEmpty {
				Section {
					DisclosureGroup("Archived Projects (\\(archivedProjects.count))", isExpanded: $showArchivedProjects) {
						ForEach(archivedProjects.sorted { $0.name < $1.name }) { project in
							ProjectRowView(project: project)
								.opacity(0.6)
						}
					}
				}
			}
		}
		.navigationTitle("Projects")
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button {
					showCreateProject = true
				} label: {
					Image(systemName: "plus")
				}
			}
		}
		.sheet(isPresented: $showCreateProject) {
			CreateProjectView()
				.presentationDetents([.medium])
		}
	}
}

struct ProjectRowView: View {
	@Bindable var project: Project
	@Environment(\.modelContext) private var modelContext
	@Environment(GlobalStore.self) private var store
	
	var body: some View {
		NavigationLink {
			ProjectDetailView(project: project)
		} label: {
			HStack(spacing: 12) {
				// Project Icon and Color
				Image(systemName: project.icon)
					.foregroundStyle(project.color.color)
					.frame(width: 24, height: 24)
				
				// Project Info
				VStack(alignment: .leading, spacing: 2) {
					HStack {
						Text(project.name)
							.font(.body)
							.foregroundStyle(.primary)
						
						if project.isFavorite {
							Image(systemName: "star.fill")
								.foregroundStyle(.yellow)
								.font(.caption)
						}
						
						Spacer()
					}
					
					// Task Count
					HStack {
						Text("\\(project.incompleteTasks.count) tasks")
							.font(.caption)
							.foregroundStyle(.secondary)
						
						if !project.completedTasks.isEmpty {
							Text("• \\(project.completedTasks.count) completed")
								.font(.caption)
								.foregroundStyle(.secondary)
						}
					}
				}
				
				Spacer()
				
				// Menu
				Menu {
					Button {
						project.isFavorite.toggle()
						try? modelContext.save()
					} label: {
						Label(project.isFavorite ? "Remove from Favorites" : "Add to Favorites",
							  systemImage: project.isFavorite ? "star.slash" : "star")
					}
					
					Button {
						project.isArchived.toggle()
						try? modelContext.save()
					} label: {
						Label(project.isArchived ? "Unarchive" : "Archive",
							  systemImage: project.isArchived ? "tray.and.arrow.up" : "archivebox")
					}
					
					Button(role: .destructive) {
						modelContext.delete(project)
						try? modelContext.save()
					} label: {
						Label("Delete", systemImage: "trash")
					}
				} label: {
					Image(systemName: "ellipsis")
						.foregroundStyle(.secondary)
						.frame(width: 32, height: 32)
						.contentShape(Rectangle())
				}
				.buttonStyle(.plain)
			}
		}
		.buttonStyle(.plain)
	}
}

#Preview {
	NavigationStack {
		ProjectsView()
			.modelContainer(for: Project.self, inMemory: true)
			.environment(GlobalStore())
	}
}