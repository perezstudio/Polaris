//
//  CreateProjectView.swift
//  Polaris
//
//  Created by Kevin Perez on 4/27/25.
//

import SwiftUI
import SwiftData

struct CreateProjectView: View {
	
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	@State var projectTitle: String = ""
	@State var projectIcon: String = "rectangle.stack.fill"
	@State var projectColor: ProjectColor = .blue
	
	var body: some View {
		NavigationStack {
			Form {
				SwiftUI.Section {
					TextField("Project Name", text:$projectTitle)
				}
				SwiftUI.Section {
					NavigationLink(destination: ProjectIconPicker(selectedSymbol: $projectIcon, selectedColor: $projectColor)) {
						HStack {
							Text("Project Icon")
							Spacer()
							Image(systemName: projectIcon)
								.foregroundStyle(projectColor.color)
						}
					}
				}
				SwiftUI.Section {
					NavigationLink(destination: ProjectColorPicker(selectedColor: $projectColor)) {
						HStack {
							Text("Project Color")
							Spacer()
							Circle()
								.foregroundColor(projectColor.color)
								.frame(height: 24)
						}
					}
				}
				Button {
					createProject()
				} label: {
					Label("Create Project", systemImage: "rectangle.stack.fill.badge.plus")
				}
			}
			.navigationTitle("Create Project")
			#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						dismiss()
					} label: {
						Label("Close", systemImage: "xmark.circle.fill")
					}
				}
			}
			#elseif os(macOS)
			.toolbar {
				ToolbarItem(placement: .navigation) {
					Button {
						dismiss()
					} label: {
						Label("Close", systemImage: "xmark.circle.fill")
					}
				}
			}
			#endif
		}
	}
	
	private func createProject() {
		let newProject = Project(title: projectTitle, icon: projectIcon, color: projectColor)
		modelContext.insert(newProject)
		
		dismiss()
	}
}

#Preview {
	CreateProjectView()
}
