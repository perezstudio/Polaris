//
//  CreateProjectView.swift
//  Polaris
//
//  Created by Kevin Perez on 10/18/24.
//

import SwiftUI

struct CreateProjectView: View {
	@Environment(\.dismiss) var dismiss
	@Environment(\.modelContext) var modelContext
	
	// Initialize with an optional project for editing
	let projectToEdit: Project?
	
	@State private var title: String
	@State private var notes: String
	@State private var status: Status
	@State private var enabledDueDate: Bool
	@State private var dueDate: Date
	@State private var enabledDeadLine: Bool
	@State private var deadline: Date
	@State private var icon: String
	@State private var color: ProjectColors
	
	// Initialize all state variables based on whether we're editing or creating
	init(project: Project? = nil) {
		self.projectToEdit = project
		
		// Initialize state with either existing project values or defaults
		_title = State(initialValue: project?.name ?? "")
		_notes = State(initialValue: project?.notes ?? "")
		_status = State(initialValue: project?.status ?? .planned)
		_enabledDueDate = State(initialValue: project?.dueDate != nil)
		_dueDate = State(initialValue: project?.dueDate ?? Date.now)
		_enabledDeadLine = State(initialValue: project?.deadLine != nil)
		_deadline = State(initialValue: project?.deadLine ?? Date.now)
		_icon = State(initialValue: project?.icon ?? "rectangle.stack")
		_color = State(initialValue: project?.color ?? .red)
	}

	var body: some View {
		NavigationStack {
			Form {
				Section {
					TextField("Project Name", text: $title)
				}
				
				Section {
					Toggle("Enable Due Date", isOn: $enabledDueDate)
					if enabledDueDate {
						DatePicker("Due Date", selection: $dueDate)
					}
					Toggle("Enable Dead Line", isOn: $enabledDeadLine)
					if enabledDeadLine {
						DatePicker("Dead Line", selection: $deadline)
					}
				}
				
				Section {
					Picker("Status", selection: $status) {
						ForEach(Status.allCases) { status in
							Text(status.name).tag(status)
						}
					}
				}
				
				Section {
					Picker("Color", selection: $color) {
						ForEach(ProjectColors.allCases) { color in
							Text(color.name).tag(color)
						}
					}
				}
				
				Section {
					Text(notes)
				}
				
				Section {
					Button {
						saveProject()
					} label: {
						Label(projectToEdit != nil ? "Update Project" : "Create Project",
							  systemImage: "rectangle.stack")
					}
				}
			}
			.navigationTitle(projectToEdit != nil ? "Edit Project" : "Create Project")
			.toolbar {
				#if os(iOS)
				ToolbarItem(placement: .navigationBarTrailing) {
					Button {
						dismiss()
					} label: {
						Label("Close", systemImage: "xmark.circle.fill")
					}
				}
				#endif
			}
		}
	}
	
	private func saveProject() {
		if let existingProject = projectToEdit {
			// Update existing project
			existingProject.name = title
			existingProject.notes = notes
			existingProject.status = status
			existingProject.dueDate = enabledDueDate ? dueDate : nil
			existingProject.deadLine = enabledDeadLine ? deadline : nil
			existingProject.icon = icon
			existingProject.color = color
		} else {
			// Create new project
			let newProject = Project(
				name: title,
				notes: notes,
				status: status,
				icon: icon,
				color: color
			)
			if enabledDueDate {
				newProject.dueDate = dueDate
			}
			if enabledDeadLine {
				newProject.deadLine = deadline
			}
			modelContext.insert(newProject)
		}
		
		dismiss()
	}
}

#Preview {
	CreateProjectView()
}

// Additional preview for editing mode
#Preview {
	CreateProjectView(project: Project(name: "Sample Project", notes: "Sample Notes", status: .planned, icon: "rectangle.stack", color: .red))
}
