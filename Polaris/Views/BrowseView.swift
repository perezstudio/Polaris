//
//  BrowseView.swift
//  Polaris
//
//  Created by Kevin Perez on 12/26/24.
//

import SwiftUI
import SwiftData

struct BrowseView: View {
	
	@Query(sort: \Project.created, order: .forward) var projects: [Project]
	@State var createProjectSheet: Bool = false
	
	var body: some View {
		NavigationView {
			ScrollView {
				VStack(spacing: 32) {
					DefaultBrowseOptions()
					VStack(spacing: 16) {
						HStack {
							Text("Projects")
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
							if (projects.isEmpty) {
								ContentUnavailableView {
									Label {
										Text("No Projects")
									} icon: {
										Image(systemName: "stack.square.fill")
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
					}
				}
			}
			.background(Color(.systemGroupedBackground))
			.navigationTitle("Browse")
			.sheet(isPresented: $createProjectSheet) {
				CreateProjectSheet()
					.presentationDetents([.medium, .large])
					.presentationDragIndicator(.visible)
			}
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button {
						print("Test Settings Button")
					} label: {
						Label("Settings", systemImage: "gear")
					}
				}
			}
		}
	}
}

#Preview {
	BrowseView()
}
