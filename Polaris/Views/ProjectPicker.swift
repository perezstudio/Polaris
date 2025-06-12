//
//  ProjectPicker.swift
//  Polaris
//
//  Created by Kevin Perez on 4/29/25.
//

import SwiftUI
import SwiftData

struct ProjectPicker: View {
	
	@Environment(\.dismiss) var dismiss
	@Query var projects: [Project]
	@Binding var selectedProject: Project?
	@Binding var selectedSection: Section?
	@Binding var inbox: Bool
	
	var body: some View {
		List {
			SwiftUI.Section {
				Button {
					inbox = true
					selectedProject = nil
					dismiss()
				} label: {
					HStack {
						Label {
							Text("Inbox")
								.foregroundStyle(Color.primary)
						} icon: {
							Image(systemName: "tray.fill")
								.font(.caption)
								.foregroundStyle(ProjectColor.blue.color)
								.frame(width: 34, height: 34)
								.background(ProjectColor.blue.color.opacity(0.2))
								.cornerRadius(10)
						}
						.padding(.vertical, 2)
						if inbox == true && selectedProject == nil {
							Spacer()
							Image(systemName: "checkmark.circle.fill")
								.foregroundStyle(ProjectColor.blue.color)
						}
					}
				}
				Button {
					selectedProject = nil
					inbox = false
					dismiss()
				} label: {
					HStack {
						Label {
							Text("No Project")
								.foregroundStyle(Color.primary)
						} icon: {
							Image(systemName: "xmark.square.fill")
								.font(.caption)
								.foregroundStyle(ProjectColor.blue.color)
								.frame(width: 34, height: 34)
								.background(ProjectColor.blue.color.opacity(0.2))
								.cornerRadius(10)
						}
						.padding(.vertical, 2)
						if inbox == false && selectedProject == nil {
							Spacer()
							Image(systemName: "checkmark.circle.fill")
								.foregroundStyle(ProjectColor.blue.color)
						}
					}
				}
			}
			SwiftUI.Section {
				if !projects.isEmpty {
					ForEach(projects) { project in
						Button(action: {
							selectedProject = project
							selectedSection = nil
							dismiss()
						}) {
							HStack {
								LabelView(project: project)
								Spacer()
								if selectedProject == project {
									Image(systemName: "checkmark.circle.fill")
										.foregroundStyle(ProjectColor.blue.color)
								}
							}
						}
					}
				} else {
					ContentUnavailableView("No Projects Available", systemImage: "rectangle.stack.fill", description: Text("You don't have any available projects."))
				}
			}
		}
	}
}

#Preview {
	@Previewable @State var newProject: Project? = nil
	@Previewable @State var newSection: Section? = Section(title: "New Section")
	@Previewable @State var isInbox: Bool = false

	ProjectPicker(selectedProject: $newProject, selectedSection: $newSection, inbox: $isInbox)
		.modelContainer(for: [Project.self, Section.self])
}
