//
//  CreateProjectView.swift
//  Polaris
//
//  Created by Kevin Perez on 8/3/25.
//

import SwiftUI
import SwiftData

struct CreateProjectView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	@State private var projectName = ""
	@State private var selectedColor: ProjectColor = .blue
	@State private var selectedIcon = "folder"
	@State private var isFavorite = false
	
	@FocusState private var isFocused: Bool
	
	let iconOptions = [
		"folder", "folder.fill", "briefcase", "briefcase.fill",
		"house", "house.fill", "heart", "heart.fill",
		"star", "star.fill", "flag", "flag.fill",
		"book", "book.fill", "car", "car.fill",
		"gamecontroller", "music.note", "camera", "photo"
	]
	
	var body: some View {
		NavigationStack {
			Form {
				Section("Project Details") {
					TextField("Project name", text: $projectName)
						.focused($isFocused)
					
					Toggle("Add to Favorites", isOn: $isFavorite)
				}
				
				Section("Appearance") {
					// Color Picker
					Picker("Color", selection: $selectedColor) {
						ForEach(ProjectColor.allCases, id: \.self) { color in
							HStack {
								Circle()
									.fill(color.color)
									.frame(width: 20, height: 20)
								Text(color.name)
							}
							.tag(color)
						}
					}
					
					// Icon Picker
					VStack(alignment: .leading, spacing: 12) {
						Text("Icon")
							.font(.headline)
						
						LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
							ForEach(iconOptions, id: \.self) { icon in
								Button {
									selectedIcon = icon
								} label: {
									Image(systemName: icon)
										.font(.title2)
										.foregroundStyle(selectedIcon == icon ? .white : selectedColor.color)
										.frame(width: 40, height: 40)
										.background(selectedIcon == icon ? selectedColor.color : Color.gray.opacity(0.1))
										.clipShape(RoundedRectangle(cornerRadius: 8))
								}
								.buttonStyle(.plain)
							}
						}
					}
				}
				
				Section {
					// Preview
					HStack {
						Image(systemName: selectedIcon)
							.foregroundStyle(selectedColor.color)
							.frame(width: 24, height: 24)
						
						VStack(alignment: .leading, spacing: 2) {
							HStack {
								Text(projectName.isEmpty ? "Project Name" : projectName)
									.font(.body)
								
								if isFavorite {
									Image(systemName: "star.fill")
										.foregroundStyle(.yellow)
										.font(.caption)
								}
							}
							
							Text("0 tasks")
								.font(.caption)
								.foregroundStyle(.secondary)
						}
						
						Spacer()
					}
					.padding(.vertical, 4)
				} header: {
					Text("Preview")
				}
			}
			.navigationTitle("New Project")
			#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
			#endif
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") {
						dismiss()
					}
				}
				
				ToolbarItem(placement: .confirmationAction) {
					Button("Create") {
						createProject()
					}
					.disabled(projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
				}
			}
			.onAppear {
				isFocused = true
			}
		}
	}
	
	private func createProject() {
		let trimmedName = projectName.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmedName.isEmpty else { return }
		
		let project = Project(
			name: trimmedName,
			color: selectedColor,
			icon: selectedIcon
		)
		project.isFavorite = isFavorite
		
		modelContext.insert(project)
		
		do {
			try modelContext.save()
			dismiss()
		} catch {
			print("Failed to create project: \\(error)")
		}
	}
}

#Preview {
	CreateProjectView()
		.modelContainer(for: Project.self, inMemory: true)
}