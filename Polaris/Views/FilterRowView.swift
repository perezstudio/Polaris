//
//  FilterRowView.swift
//  Polaris
//
//  Created by Kevin Perez on 10/26/24.
//

import SwiftUI

struct FilterRowView: View {
	
	@State var projectName: String
	@State var projectColor: Color
	@State var projectIcon: String
	
    var body: some View {
		HStack(spacing: 10) {
			ZStack {
				RoundedRectangle(cornerRadius: 6)
					.strokeBorder(projectColor,
						lineWidth: 1
					)
					.background(
						RoundedRectangle(cornerRadius: 10)
							.fill(projectColor.opacity(0.15))
					)
					.frame(width: 30, height: 30)
				
				Image(systemName: projectIcon)
					.font(.system(size: 16))
					.fontWeight(.semibold)
					.foregroundColor(projectColor)
			}
			Text(projectName)
		}
		.padding(.vertical, 4)
    }
}

#Preview {
	
	@Previewable @State var newProjectName: String = "Testing 1"
	@Previewable @State var newProjectColor: Color = .red
	@Previewable @State var newProjectIcon: String = "person.crop.circle.badge.plus"
	
	FilterRowView(projectName: newProjectName, projectColor: newProjectColor, projectIcon: newProjectIcon)
}
