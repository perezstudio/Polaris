//
//  CreateProjectSheet.swift
//  Polaris
//
//  Created by Kevin Perez on 12/27/24.
//

import SwiftUI
import SwiftData

struct CreateProjectSheet: View {
	
	@Environment(\.modelContext) private var context
	@Environment(\.dismiss) var dismiss
	@State var projectTitle: String = ""
	@State var projectIcon: String = "square.stack.fill"
	@State var projectColor: ColorPalette = .blue
	@State var projectDescription: String = ""
	@State var iconPickerSheet: Bool = false
	@State var colorPickerSheet: Bool = false
	@FocusState private var focusedField: FocusedField?
	
    var body: some View {
		NavigationStack {
			ScrollView(showsIndicators: false) {
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
							iconPickerSheet.toggle()
						} label: {
							Label("Project Icon", systemImage: projectIcon)
								.labelStyle(.iconOnly)
								.foregroundStyle(projectColor.color)
						}
						Spacer()
						Button {
							colorPickerSheet.toggle()
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
			.sheet(isPresented: $iconPickerSheet) {
				SymbolGridView(projectIcon: $projectIcon)
			}
			.sheet(isPresented: $colorPickerSheet) {
				ColorPickerView(selectedColor: $projectColor)
			}
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button {
						dismiss()
					} label: {
						Label("Cancel", systemImage: "xmark.circle.fill")
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button {
						addProject()
						dismiss()
					} label: {
						Label("Create", systemImage: "rectangle.stack.fill.badge.plus")
					}
				}
			}
		}
    }
	
	private func addProject() {
		// Create a new local project
		let newProject = Project(
			title: projectTitle,
			status: .InProgress,
			favorite: false,
			icon: projectIcon,
			color: projectColor,
			todos: []
		)
		
		// Insert the project into the local database
		context.insert(newProject)
		
		// Close the view
		dismiss()
	}
}

#Preview {
	// Create a mock ModelContainer with the Project schema
	let container = try! ModelContainer(for: Project.self)
	
	return CreateProjectSheet(
		projectTitle: "New Project",
		projectIcon: "stack.fill",
		projectColor: ColorPalette.blue,
		projectDescription: "This is my new project for the Polaris app"
	)
	.modelContainer(container) // Inject the container into the view
}
