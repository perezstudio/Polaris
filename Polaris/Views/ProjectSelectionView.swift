//
//  ProjectSelectionView.swift
//  Polaris
//
//  Created by Kevin Perez on 12/12/24.
//

// Add these imports
import SwiftUI
import SwiftData

struct ProjectSelectionView: View {
	@Binding var selectedProject: Project?
	@Binding var inbox: Bool // Add this property
	@Query(sort: \Project.name) private var allProjects: [Project]
	@Environment(\.dismiss) private var dismiss
	
	private var activeProjects: [Project] {
		allProjects.filter { project in
			project.status != .cancelled && project.status != .archived
		}
	}
	
	var body: some View {
		List {
			Section {
				Button {
					selectedProject = nil
					inbox = true
					dismiss()
				} label: {
					HStack {
						HStack(spacing: 10) {
							ZStack {
								RoundedRectangle(cornerRadius: 6)
									.strokeBorder(Color.blue, lineWidth: 1)
									.background(
										RoundedRectangle(cornerRadius: 10)
											.fill(Color.blue.opacity(0.15))
									)
									.frame(width: 30, height: 30)
								
								Image(systemName: "tray.fill")
									.font(.system(size: 16))
									.fontWeight(.semibold)
									.foregroundColor(Color.blue)
							}
							Text("Inbox")
						}
						Spacer()
						if inbox && selectedProject == nil {
							Image(systemName: "checkmark.circle.fill")
								.foregroundColor(.blue)
						}
					}
					.padding(.vertical, 4)
				}
			}
			
			Section {
				Button {
					selectedProject = nil
					inbox = false
					dismiss()
				} label: {
					HStack {
						HStack(spacing: 10) {
							ZStack {
								RoundedRectangle(cornerRadius: 6)
									.strokeBorder(Color.blue, lineWidth: 1)
									.background(
										RoundedRectangle(cornerRadius: 10)
											.fill(Color.blue.opacity(0.15))
									)
									.frame(width: 30, height: 30)
								
								Image(systemName: "xmark.square")
									.font(.system(size: 16))
									.fontWeight(.semibold)
									.foregroundColor(Color.blue)
							}
							Text("No Project")
						}
						Spacer()
						if !inbox && selectedProject == nil {
							Image(systemName: "checkmark.circle.fill")
								.foregroundColor(.blue)
						}
					}
					.padding(.vertical, 4)
				}
			}
			
			if !activeProjects.isEmpty {
				Section("Projects") {
					ForEach(activeProjects) { project in
						Button {
							selectedProject = project
							inbox = false
							dismiss()
						} label: {
							HStack {
								ProjectRowView(project: project)
								Spacer()
								if !inbox && selectedProject == project {
									Image(systemName: "checkmark.circle.fill")
										.foregroundColor(.blue)
								}
							}
						}
					}
				}
			}
		}
		.listStyle(.insetGrouped)
	}
}

// End of file
