//
//  CreateTodoView.swift
//  Polaris
//
//  Created by Kevin Perez on 10/18/24.
//

import SwiftUI
import SwiftData

struct CreateTodoView: View {
	@Environment(\.modelContext) var modelContext
	@Environment(\.dismiss) var dismiss
	@Query(sort: \Project.name) private var projects: [Project]
	@State var title: String = ""
	@State var notes: String = ""
	@State var enableDueDate: Bool = false
	@State var dueDate: Date = Date.now
	@State var enableDeadline: Bool = false
	@State var dateLine: Date = Date.now
	@State var inbox: Bool = false
	@Binding var project: Project?
	@State private var selectedProject: Project?

	init(project: Binding<Project?> = .constant(nil)) {
		_project = project
		_selectedProject = State(initialValue: project.wrappedValue)
	}
	
	var body: some View {
		NavigationStack {
			Form {
				Section {
					TextField("Task Title", text: $title)
				}
				Section {
					Toggle("Enable Due Date", isOn: $enableDueDate)
					if(enableDueDate) {
						DatePicker("Due Date", selection: $dueDate)
					}
					Toggle("Enable Deadline", isOn: $enableDeadline)
					if(enableDeadline) {
						DatePicker("Date Line", selection: $dateLine)
					}
				}
				Section {
					Toggle("Add to Inbox", isOn: $inbox)
					if(!inbox) {
						Picker("Project", selection: $selectedProject) {
							Text("No Project").tag(nil as Project?)
							ForEach(projects) { project in
								Text(project.name).tag(project as Project?)
							}
						}
					}
				}
				Section(header: Text("Notes")) {
					TextEditor(text: $notes)
				}
				Section {
					Button {
						createTodo()
					} label: {
						Label("Create Todo", systemImage: "plus")
					}
				}
			}
			.navigationTitle("Create Todo")
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
	
	private func createTodo() {
		let newTodo = Todo(
			title: title,
			status: false,
			notes: notes,
			dueDate: enableDueDate ? dueDate : nil,
			deadLine: enableDeadline ? dateLine : nil,
			project: selectedProject,
			inbox: inbox
		)
		
		modelContext.insert(newTodo)
		
		if let selectedProject = selectedProject {
			selectedProject.todos.append(newTodo)
		}
		
		try? modelContext.save()
		project = selectedProject
		dismiss()
	}
}

#Preview {
	CreateTodoView()
		.modelContainer(for: Project.self, inMemory: true)
}
