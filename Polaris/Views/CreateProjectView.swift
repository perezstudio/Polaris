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
	@State var title: String = ""
	@State var notes: String = ""
	@State var status: Status = .planned
	@State var enabledDueDate: Bool = false
	@State var dueDate: Date = Date.now
	@State var enabledDeadLine: Bool = false
	@State var deadline: Date = Date.now
	@State var icon: String = "rectangle.stack"
	@State var color: ProjectColors = .red
	
    var body: some View {
		NavigationStack {
			Form {
				Section {
					TextField("Project Name", text: $title)
				}
				Section {
					Toggle("Enable Due Date", isOn: $enabledDueDate)
					if(enabledDueDate) {
						DatePicker("Due Date", selection: $dueDate)
					}
					Toggle("Enable Dead Line", isOn: $enabledDeadLine)
					if(enabledDeadLine) {
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
						createProject()
					} label: {
						Label("Create Project", systemImage: "rectangle.stack")
					}
				}
			}
			.navigationTitle("Create Project")
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button {
						dismiss()
					} label: {
						Label("Close", systemImage: "xmark.circle.fill")
					}
				}
			}
		}
    }
	
	private func createProject() {
		let newProject = Project(name: title, notes: notes, status: status, icon: icon, color: color)
		modelContext.insert(newProject)
		dismiss()
	}
}

#Preview {
    CreateProjectView()
}
