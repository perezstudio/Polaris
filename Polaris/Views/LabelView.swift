//
//  LabelView.swift
//  Polaris
//
//  Created by Kevin Perez on 4/24/25.
//

import SwiftUI
import SwiftData

struct LabelView: View {
	
	@Bindable var project: Project
	
	var body: some View {
		Label {
			Text(project.title)
		} icon: {
			Image(systemName: project.icon)
				.font(.caption)
				.foregroundStyle(project.color.color)
				.frame(width: 34, height: 34)
				.background(project.color.color.opacity(0.2))
				.cornerRadius(10)
		}
		.padding(.vertical, 2)
	}
}


