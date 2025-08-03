//
//  SidebarView.swift
//  Polaris
//
//  Created by Kevin Perez on 4/24/25.
//

import SwiftUI
import SwiftData

struct SidebarView: View {
	
	@Environment(\.modelContext) private var modelContext
	@Environment(GlobalStore.self) private var store
	
	@Query(filter: #Predicate<Project> { !$0.isArchived && $0.isFavorite })
	private var favoriteProjects: [Project]
	
	@Query(filter: #Predicate<Project> { !$0.isArchived && !$0.isFavorite })
	private var regularProjects: [Project]
	
	@Query(filter: #Predicate<Task> { !$0.isCompleted && $0.project == nil })
	private var inboxTasks: [Task]
	
	@Query(filter: #Predicate<Task> { !$0.isCompleted && $0.dueDate != nil })
	private var tasksWithDates: [Task]
	
	@State var showCreateProject: Bool = false
	@State var showAddTask: Bool = false
	
	var todayTaskCount: Int {
		tasksWithDates.filter { $0.isToday }.count
	}
	
	var overdueTaskCount: Int {
		tasksWithDates.filter { $0.isOverdue }.count
	}
	
	var body: some View {
		NavigationStack {
			List {
				// Main Views
				Section {
					NavigationLink(destination: InboxView()) {
						Label {
							HStack {
								Text("Inbox")
								Spacer()
								if inboxTasks.count > 0 {
									Text("\(inboxTasks.count)")
										.font(.caption)
										.foregroundStyle(.secondary)
								}
							}
						} icon: {
							Image(systemName: "tray.fill")
								.foregroundStyle(.blue)
						}
					}
					
					NavigationLink(destination: TodayView()) {
						Label {
							HStack {
								Text("Today")
								Spacer()
								if todayTaskCount > 0 || overdueTaskCount > 0 {
									Text("\(todayTaskCount + overdueTaskCount)")
										.font(.caption)
										.foregroundStyle(overdueTaskCount > 0 ? .red : .secondary)
								}
							}
						} icon: {
							Image(systemName: "calendar")
								.foregroundStyle(.green)
						}
					}
					
					NavigationLink(destination: UpcomingView()) {
						Label {
							Text("Upcoming")
						} icon: {
							Image(systemName: "calendar.badge.clock")
								.foregroundStyle(.orange)
						}
					}
				}
				
				// Favorite Projects
				if !favoriteProjects.isEmpty {
					Section("Favorites") {
						ForEach(favoriteProjects.sorted { $0.name < $1.name }) { project in
							NavigationLink(destination: ProjectDetailView(project: project)) {
								Label {
									HStack {
										Text(project.name)
										Spacer()
										if project.incompleteTasks.count > 0 {
											Text("\(project.incompleteTasks.count)")
												.font(.caption)
												.foregroundStyle(.secondary)
										}
									}
								} icon: {
									Image(systemName: project.icon)
										.foregroundStyle(project.color.color)
								}
							}
						}
					}
				}
				
				// Projects Section
				Section {
					NavigationLink(destination: ProjectsView()) {
						Label {
							Text("Projects")
						} icon: {
							Image(systemName: "folder")
								.foregroundStyle(.purple)
						}
					}
					
					// Recent Projects
					ForEach(regularProjects.sorted { $0.name < $1.name }.prefix(5)) { project in
						NavigationLink(destination: ProjectDetailView(project: project)) {
							Label {
								HStack {
									Text(project.name)
									Spacer()
									if project.incompleteTasks.count > 0 {
										Text("\(project.incompleteTasks.count)")
											.font(.caption)
											.foregroundStyle(.secondary)
									}
								}
							} icon: {
								Image(systemName: project.icon)
									.foregroundStyle(project.color.color)
							}
						}
					}
				}
			}
			.navigationTitle("Polaris")
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Button {
						showAddTask = true
					} label: {
						Image(systemName: "plus")
					}
				}
				
				ToolbarItem(placement: .secondaryAction) {
					Button {
						showCreateProject = true
					} label: {
						Image(systemName: "folder.badge.plus")
					}
				}
			}
			.sheet(isPresented: $showCreateProject) {
				CreateProjectView()
			}
			.sheet(isPresented: $showAddTask) {
				AddTaskView()
					.presentationDetents([.medium])
			}
		}
	}
}

#Preview {
	NavigationStack {
		SidebarView()
	}
	.modelContainer(for: Project.self, inMemory: true)
	.environment(GlobalStore())
}
