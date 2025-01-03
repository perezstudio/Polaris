//
//  BrowseView.swift
//  Polaris
//
//  Created by Kevin Perez on 12/26/24.
//

import SwiftUI
import SwiftData

struct BrowseView: View {
	
	@ObservedObject var authManager: AuthManager
	@Query(sort: \Project.created, order: .forward) var projects: [Project]
	@State var createProjectSheet: Bool = false
	@State var accountSheet: Bool = false
	@State var settingsSheet: Bool = false
	
	var syncManager: SyncManager
	
	var body: some View {
		NavigationView {
			ScrollView(showsIndicators: false) {
				VStack(spacing: 32) {
					DefaultBrowseOptions()
					VStack(spacing: 16) {
						HStack {
							Text("Projects")
								.font(.subheadline)
								.textCase(.uppercase)
								.foregroundStyle(Color.gray.opacity(0.80))
							Spacer()
							Button {
								createProjectSheet.toggle()
							} label: {
								Label {
									Text("Create New Project")
								} icon: {
									Image(systemName: "plus")
								}
								.labelStyle(.iconOnly)
							}
						}
						.padding(.horizontal, 32)
						VStack {
							VStack {
								if (projects.isEmpty) {
									ContentUnavailableView {
										Label {
											Text("No Projects")
										} icon: {
											Image(systemName: "square.stack.fill")
												.foregroundStyle(Color.blue)
										}
									} description: {
										Text("Way to go! You've completed all your tasks for today! Keep it up!")
									} actions: {
										Button {
											createProjectSheet.toggle()
										} label: {
											Label("Create New Project", systemImage: "plus")
										}
									}
								} else {
									ForEach(projects, id: \Project.id) { project in
										NavigationLink(destination: ProjectView(project: project)) {
											MenuItem(icon: project.icon, title: project.title, color: project.color.color)
										}
									}
								}
							}
							.background(Color(.secondarySystemGroupedBackground))
							.cornerRadius(12)
						}
						.padding(.horizontal, 16)
					}
				}
			}
			.background(Color(.systemGroupedBackground))
			.navigationTitle("Browse")
			.sheet(isPresented: $createProjectSheet) {
				CreateProjectSheet(syncManager: syncManager)
					.presentationDetents([.medium, .large])
					.presentationDragIndicator(.visible)
			}
			.sheet(isPresented: $accountSheet) {
				AccountView(authManager: authManager)
					.presentationDragIndicator(.visible)
			}
			.sheet(isPresented: $settingsSheet) {
				SettingsView()
					.presentationDragIndicator(.visible)
			}
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button {
						accountSheet.toggle()
					} label: {
						Label("Account", systemImage: "person.crop.circle")
					}
				}
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						settingsSheet.toggle()
					} label: {
						Label("Settings", systemImage: "gear")
					}
				}
			}
		}
	}
}

#Preview {
	let mockAuthManager = MockAuthManager()
	let container = try! ModelContainer(for: Project.self)
	let syncManager = SyncManager(context: container.mainContext)
	BrowseView(authManager: mockAuthManager, syncManager: syncManager)
}
