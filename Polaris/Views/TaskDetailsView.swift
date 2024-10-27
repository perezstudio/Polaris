//
//  TaskDetailsView.swift
//  Polaris
//
//  Created by Kevin Perez on 10/24/24.
//

import SwiftUI

struct TaskDetailsView: View {
	
	@Bindable var todo: Todo
	@State var openProjectPickerSheet: Bool = false
	@State var dueDatePicker: Bool = false
	@State var deadLinePicker: Bool = false
	
    var body: some View {
		NavigationStack {
			List {
				Section {
					HStack(spacing: 16) {
						TodoCheckboxView(isChecked: $todo.status)
						TextField("Title", text: $todo.title)
							.frame(maxWidth: .infinity, alignment: .leading)
					}
				}
				if(todo.project != nil) {
					Section(header: Text("Project")) {
						Button {
							openProjectPickerSheet.toggle()
						} label: {
							ProjectRowView(project: todo.project ?? Project(id: UUID(), name: "", notes: "", status: .inProgress, icon: "square.stack", color: ProjectColors.red))
						}
						.foregroundStyle(.primary)
					}
				}
				Section(header: Text("Dates")) {
					Button {
						dueDatePicker.toggle()
					} label: {
						TaskDateView(dateType: "Due Date", todo: todo, calendarPicker: $dueDatePicker)
					}
					.foregroundStyle(.primary)
					Button {
						deadLinePicker.toggle()
					} label: {
						TaskDateView(dateType: "Deadline", todo: todo, calendarPicker: $deadLinePicker)
					}
					.foregroundStyle(.primary)
				}
				Section(header: Text("Notes")) {
					TextEditor(text: $todo.notes)
				}
			}
			.navigationTitle(todo.title)
			.navigationBarTitleDisplayMode(.large)
			.sheet(isPresented: $openProjectPickerSheet) {
				ProjectPickerView()
			}
		}
    }
}

#Preview {
	
	var newProject = Project(id: UUID(), name: "New Project", notes: "Description", status: .inProgress, icon: "square.stack", color: ProjectColors.red)
	var newTodo = Todo(title: "New Task", status: false, notes: "Description", project: newProject, inbox: false)
	
	TaskDetailsView(todo: newTodo)
		.modelContainer(for: [Todo.self, Project.self], inMemory: true)
}
