//
//  TodoCheckboxView.swift
//  Polaris
//
//  Created by Kevin Perez on 10/25/24.
//

import SwiftUI

struct TodoCheckboxView: View {
	
	@Binding var isChecked: Bool
	
    var body: some View {
		Button {
			isChecked.toggle()
		} label: {
			ZStack {
				RoundedRectangle(cornerRadius: 6)
					.strokeBorder(
						isChecked ? .blue : .gray.opacity(0.3),
						lineWidth: 2
					)
					.background(
						RoundedRectangle(cornerRadius: 6)
							.fill(isChecked ? .blue : .clear)
					)
					.frame(width: 24, height: 24)
				
				Image(systemName: "checkmark")
					.font(.system(size: 14))
					.fontWeight(.semibold)
					.foregroundColor(.white)
					.opacity(isChecked ? 1 : 0)
			}
		}
    }
}

//#Preview {
//	
//	@State var newTodo = Todo(title: "New Task", status: false, notes: "Description", project: newProject, inbox: false)
//	
//	var newProject = Project(id: UUID(), name: "New Project", notes: "Description", status: .inProgress, icon: "square.stack", color: ProjectColors.red)
//	
//	TodoCheckboxView(isChecked: $newTodo.status)
//		.modelContainer(for: [Todo.self, Project.self], inMemory: true)
//}
