//
//  MainMenuView.swift
//  Polaris
//
//  Created by Kevin Perez on 10/18/24.
//

import SwiftUI
import SwiftData

struct MainMenuView: View {
	
	@Environment(\.modelContext) private var modelContext
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	@Query private var projects: [Project]
	@Query private var items: [Item]
	@Binding var selectedProject: Project?
	@State var openCreateProjectSheet: Bool = false
	@State var openCreateTaskSheet: Bool = false
	@State var openSettingsSheet: Bool = false
	
    var body: some View {
		NavigationStack {
			List {
				Section {
					NavigationLink(destination: FilteredTodoView(filter: .inbox)) {
						FilterRowView(projectName: "Inbox", projectColor: .blue, projectIcon: "tray.fill")
					}
				}
				Section {
					NavigationLink(destination: FilteredTodoView(filter: .today)) {
						FilterRowView(projectName: "Today", projectColor: .yellow, projectIcon: "star.fill")
					}
					NavigationLink(destination: FilteredTodoView(filter: .upcoming)) {
						FilterRowView(projectName: "Upcoming", projectColor: .red, projectIcon: "calendar")
					}
					NavigationLink(destination: FilteredTodoView(filter: .all)) {
						FilterRowView(projectName: "All My Tasks", projectColor: .teal, projectIcon: "checklist")
					}
					NavigationLink(destination: FilteredTodoView(filter: .completed)) {
						FilterRowView(projectName: "Logbook", projectColor: .green, projectIcon: "checkmark.circle.fill")
					}
				}
				Section(header: Text("Projects")) {
					ForEach(projects) { project in
						NavigationLink(destination: ProjectView(project: project) ) {
							ProjectRowView(project: project)
						}
					}
					.onDelete(perform: deleteItems)
				}
			}
#if os(macOS)
			.navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
			.toolbar {
#if os(iOS)
				ToolbarItem(placement: .navigationBarTrailing) {
					Button {
						print("Settings Open")
					} label: {
						Label("Settings", systemImage: "person.crop.circle")
					}
				}
#endif
				ToolbarItemGroup(placement: .bottomBar) {
					Button {
						openCreateProject()
					} label: {
						Label("Add Project", systemImage: "rectangle.stack.badge.plus")
					}
					Spacer()
				}
			}
			.sheet(isPresented: $openCreateProjectSheet) {
				CreateProjectView()
			}
			.sheet(isPresented: $openCreateTaskSheet) {
				if (selectedProject != nil) {
					CreateTodoView(project: $selectedProject)
				} else {
					CreateTodoView()
				}
			}
		}
    }
	
	private func openCreateProject() {
		withAnimation {
			openCreateProjectSheet.toggle()
		}
	}
	
	private func openCreateTask() {
		withAnimation {
			openCreateTaskSheet.toggle()
		}
	}

	private func deleteItems(offsets: IndexSet) {
		withAnimation {
			for index in offsets {
				modelContext.delete(items[index])
			}
		}
	}
	
}

#Preview {
	@State var newProject = Project(id: UUID(), name: "New Project", notes: "", status: .inProgress , icon: "square.and.arrow.up.fill", color: ProjectColors(rawValue: "red")!)
	
	MainMenuView(selectedProject: .constant(newProject))
		.modelContainer(for: Project.self, inMemory: true)
	
}
