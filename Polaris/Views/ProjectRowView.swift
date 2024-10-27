//
//  ProjectRowView.swift
//  Polaris
//
//  Created by Kevin Perez on 10/26/24.
//

import SwiftUI

struct ProjectRowView: View {
	
	// Bindings for observable updates
	@Bindable var project: Project
	
    var body: some View {
		HStack(spacing: 10) {
			ZStack {
				RoundedRectangle(cornerRadius: 6)
					.strokeBorder(project.color.color,
						lineWidth: 1
					)
					.background(
						RoundedRectangle(cornerRadius: 10)
							.fill(project.color.color.opacity(0.15))
					)
					.frame(width: 30, height: 30)
				
				Image(systemName: project.icon)
					.font(.system(size: 16))
					.fontWeight(.semibold)
					.foregroundColor(project.color.color)
			}
			Text(project.name)
		}
		.padding(.vertical, 4)
    }
}

#Preview {
	
	var newProject = Project(id: UUID(), name: "New Project", notes: "plus", dueDate: nil, deadLine: nil, status: .inProgress, icon: "plus", color: ProjectColors(rawValue: "red") ?? .red)
	
	ProjectRowView(project: newProject)
}
