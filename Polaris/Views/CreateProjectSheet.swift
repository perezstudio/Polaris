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
	
	// Add optional project parameter for editing
	var projectToEdit: Project?
	
	init(projectToEdit: Project? = nil) {
		self.projectToEdit = projectToEdit
		// Initialize state properties with existing project values if editing
		if let project = projectToEdit {
			_projectTitle = State(initialValue: project.title)
			_projectIcon = State(initialValue: project.icon)
			_projectColor = State(initialValue: project.color)
		}
	}
	
	private var isEditing: Bool {
		projectToEdit != nil
	}
	
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
			.navigationTitle(isEditing ? "Edit Project" : "New Project")
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
						if isEditing {
							updateProject()
						} else {
							addProject()
						}
						dismiss()
					} label: {
						Label(isEditing ? "Save" : "Create",
							  systemImage: isEditing ? "checkmark.circle.fill" : "rectangle.stack.fill.badge.plus")
					}
					.disabled(projectTitle.isEmpty)
				}
			}
		}
	}
	
	private func addProject() {
		let newProject = Project(
			title: projectTitle,
			status: .InProgress,
			favorite: false,
			icon: projectIcon,
			color: projectColor,
			todos: []
		)
		
		context.insert(newProject)
		try? context.save()
	}
	
	private func updateProject() {
		guard let project = projectToEdit else { return }
		
		project.title = projectTitle
		project.icon = projectIcon
		project.color = projectColor
		
		try? context.save()
	}
}

#Preview {
	let container = try! ModelContainer(for: Project.self)
	
	return CreateProjectSheet()
		.modelContainer(container)
}

// Add another preview for editing mode
#Preview {
	let container = try! ModelContainer(for: Project.self)
	let previewProject = Project(
		title: "Preview Project",
		icon: "star",
		color: .red
	)
	
	CreateProjectSheet(projectToEdit: previewProject)
		.modelContainer(container)
}
