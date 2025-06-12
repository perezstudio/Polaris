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
	@Query(sort: \Project.id) var projects: [Project]
	@State var showSettingsSheet: Bool = false
	@State var showCreateProjectSheet: Bool = false
	@State var showCreateTodoSheet: Bool = false
	
	let menuData: [MenuSection] = [
		MenuSection(title: nil, items: [
			MenuItem(title: "Inbox", icon: "tray.fill", color: .blue, destination: InboxView())
		]),
		MenuSection(title: nil, items: [
			MenuItem(title: "Today", icon: "star.fill", color: .yellow,destination: TodayView()),
			MenuItem(title: "Scheduled", icon: "calendar", color: .red,destination: ScheduledView()),
			MenuItem(title: "All Todos", icon: "checkmark.circle.fill", color: .mint,destination: FilterView()),
			MenuItem(title: "Logbook", icon: "checklist", color: .green,destination: FilterView())
		])
	]
	
	var body: some View {
		NavigationStack {
			List {
				SwiftUI.ForEach(menuData) { section in
					SwiftUI.Section {
						menuItemsForSection(section)
					}
				}
				SwiftUI.Section(header: Text("Projects")) {
					if !projects.isEmpty {
						ForEach(projects) { project in
							NavigationLink(destination: ProjectView(project: project)) {
								LabelView(project: project)
							}
						}
					} else {
						ContentUnavailableView(
								"No Projects",
								systemImage: "rectangle.stack.fill",
								description: Text("You haven't created any projects yet.")
							)
					}
				}
			}
			#if os(iOS)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						showSettingsSheet.toggle()
					} label: {
						Label("Settings", systemImage: "gear")
					}
				}
				ToolbarItemGroup(placement: .bottomBar) {
					Button {
						showCreateProjectSheet.toggle()
					} label: {
						Label("New Project", systemImage: "rectangle.stack.fill.badge.plus")
					}
					Spacer()
					Button {
						showCreateTodoSheet.toggle()
					} label: {
						Label("New Todo", systemImage: "plus.square.fill")
					}
				}
			}
			#elseif os(macOS)
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Button {
						showCreateProjectSheet.toggle()
					} label: {
						Label("New Project", systemImage: "rectangle.stack.fill")
					}
				}
				ToolbarItem(placement: .secondaryAction) {
					Button {
						showCreateTodoSheet.toggle()
					} label: {
						Label("New Todo", systemImage: "checkmark.circle.fill")
					}
				}
			}
			#endif
			.sheet(isPresented: $showSettingsSheet) {
				SettingsView()
			}
			.sheet(isPresented: $showCreateProjectSheet) {
				CreateProjectView()
			}
			.sheet(isPresented: $showCreateTodoSheet) {
				CreateTodoView()
			}
		}
	}
	
	@ViewBuilder
	func menuItemsForSection(_ section: MenuSection) -> some View {
		ForEach(section.items) { item in
			NavigationLink(destination: item.destination) {
				Label {
					Text(item.title)
				} icon: {
					Image(systemName: item.icon)
						.font(.caption)
						.foregroundStyle(item.color)
						.frame(width: 34, height: 34)
						.background(item.color.opacity(0.2))
						.cornerRadius(10)
				}
				.padding(.vertical, 2)
			}
		}
	}
}

#Preview {
	SidebarView()
}
