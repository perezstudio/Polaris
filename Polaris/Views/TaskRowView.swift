//
//  TaskRowView.swift
//  Polaris
//
//  Created by Kevin Perez on 10/25/24.
//

import SwiftUI

struct TaskRowView: View {
	
	@Bindable var todo: Todo
	
    var body: some View {
		HStack(spacing: 16) {
			TodoCheckboxView(isChecked: $todo.status)
			VStack(alignment: .leading) {
				Text(todo.title)
					.fontWeight(.semibold)
				if(todo.dueDate != nil) {
					Text(todo.dueDate?.formatted(date: .abbreviated, time: .omitted) ?? Date.now.formatted(date: .abbreviated, time: .omitted))
						.foregroundStyle(Color.gray.opacity(0.80))
				}
			}
			.foregroundStyle(Color.primary)
		}
		.padding(.vertical, 8)
    }
}

#Preview {
	
	let newProject = Project(id: UUID(), name: "New Project", notes: "Description", status: .inProgress, icon: "square.stack", color: ProjectColors.red)
	let newTodo = Todo(title: "New Task", status: false, notes: "Description", project: newProject, inbox: false)
	
	TaskRowView(todo: newTodo)
		.modelContainer(for: [Todo.self, Project.self], inMemory: true)
}
