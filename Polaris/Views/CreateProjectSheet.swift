//
//  CreateProjectSheet.swift
//  Polaris
//
//  Created by Kevin Perez on 12/27/24.
//

import SwiftUI

struct CreateProjectSheet: View {
	
	@Environment(\.dismiss) var dismiss
	@State var projectTitle: String = ""
	@State var projectIcon: String = "square.stack.fill"
	@State var projectColor: ColorPalette = .blue
	@State var projectDescription: String = ""
	@FocusState private var focusedField: FocusedField?
	
    var body: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: 24) {
					VStack(spacing: 16) {
						TextField("New Project", text: $projectTitle, axis: .vertical)
							.focused($focusedField, equals: .title)
							.onAppear {
								self.focusedField = .title
							}
						TextField("Description", text: $projectDescription, axis: .vertical)
					}
					HStack {
						Button {
							print("Icon Button Test")
						} label: {
							Label("Project Icon", systemImage: projectIcon)
								.labelStyle(.iconOnly)
								.foregroundStyle(projectColor.color)
						}
						Spacer()
						Button {
							print("Color Button Test")
						} label: {
							Label("Project Color", systemImage: "circle.fill")
								.labelStyle(.iconOnly)
								.foregroundStyle(projectColor.color)
						}
					}
				}
				.padding()
			}
			.navigationTitle("New Project")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .destructiveAction) {
					Button {
						dismiss()
					} label: {
						Label("Close", systemImage: "xmark.circle.fill")
							.foregroundStyle(projectColor.color)
					}
				}
				ToolbarItem(placement: .topBarLeading) {
					Button {
						print("Create Project")
						dismiss()
					} label: {
						Label("Create", systemImage: "checkmark.circle.fill")
							.foregroundStyle(projectColor.color)
					}
				}
			}
		}
    }
}

#Preview {
	CreateProjectSheet(projectTitle: "New Project", projectIcon: "stack.fill", projectColor: .blue, projectDescription: "This is my new project for the Polaris app")
}
