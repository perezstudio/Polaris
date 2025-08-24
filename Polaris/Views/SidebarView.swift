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
	private var projects: [Project]
	
	@Query(filter: #Predicate<Task> { !$0.isCompleted && $0.project == nil })
	private var inboxTasks: [Task]
	
	@Query(filter: #Predicate<Task> { !$0.isCompleted && $0.dueDate != nil })
	private var tasksWithDates: [Task]
	
	@State var showCreateProject: Bool = false
	@State var showAddTask: Bool = false
	@State var showSettingsSheet: Bool = false
	
	var todayTaskCount: Int {
		tasksWithDates.filter { $0.isToday }.count
	}
	
	var overdueTaskCount: Int {
		tasksWithDates.filter { $0.isOverdue }.count
	}

	var todayIconName: String {
		let today = Calendar.current.component(.day, from: Date())
		return "\(today).calendar"
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
				}
				Section {
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
							Image(systemName: todayIconName)
								.foregroundStyle(.yellow)
						}
					}
					
					NavigationLink(destination: UpcomingView()) {
						Label {
							Text("Upcoming")
						} icon: {
							Image(systemName: "calendar.badge.clock")
								.foregroundStyle(.red)
						}
					}
					
					NavigationLink(destination: UpcomingView()) {
						Label {
							Text("All Todos")
						} icon: {
							Image(systemName: "checklist")
								.foregroundStyle(.teal)
						}
					}
					
					NavigationLink(destination: UpcomingView()) {
						Label {
							Text("Logbook")
						} icon: {
							Image(systemName: "checkmark.circle.fill")
								.foregroundStyle(.green)
						}
					}
				}
				Section {
					NavigationLink(destination: ProjectsView()) {
						Label {
							HStack {
								Text("Projects")
								Spacer()
								if todayTaskCount > 0 || overdueTaskCount > 0 {
									Text("\(todayTaskCount + overdueTaskCount)")
										.font(.caption)
										.foregroundStyle(overdueTaskCount > 0 ? .red : .secondary)
								}
							}
						} icon: {
							Image(systemName: "folder")
								.foregroundStyle(.blue)
						}
					}
				}
				Section(header: Text("Favorite Projects")) {
					if !projects.isEmpty {
						ForEach(projects, id:\.name) { project in
							NavigationLink(destination: ProjectDetailView(project: project)) {
								Label {
									HStack {
										Text(project.name)
										Spacer()
									}
								} icon: {
									Image(systemName: project.icon)
										.foregroundStyle(.blue)
								}
							}
						}
					} else {
						ContentUnavailableView {
							Label("No Projects", systemImage: "folder")
						} description: {
							Text("Create A Project To Have It Appear Here.")
						} actions: {
							Button("Create Project") {
								showCreateProject = true
							}
						}
					}
				}
	
			}
			.toolbar {
				ToolbarItemGroup(placement: .bottomBar) {
					Button {
						showAddTask = true
					} label: {
						Image(systemName: "plus")
					}
					Spacer()
					Button {
						showCreateProject = true
					} label: {
						Image(systemName: "folder.badge.plus")
					}
				}
			}
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						showSettingsSheet = true
					} label: {
						Image(systemName: "gear")
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
			.sheet(isPresented: $showSettingsSheet) {
				SettingsView()
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
