//
//  CreateTodoView.swift
//  Polaris
//
//  Created by Kevin Perez on 4/27/25.
//

import SwiftUI
import SwiftData

struct CreateTodoView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	@State var todoTitle: String = ""
	@State var todoDescriptionAttr: NSAttributedString = NSAttributedString(string: "")
	@State var isInboxSelected: Bool = true
	@State var dueDate: Date? = nil
	@State var deadline: Date? = nil
	@State var selectedProject: Project? = nil
	@State var selectedSection: Section? = nil

	var body: some View {
		NavigationStack {
			Form {
				SwiftUI.Section(header: Text("Todo Title")) {
					TextField("Todo Title", text: $todoTitle)
				}
				SwiftUI.Section(header: Text("Todo Description")) {
					NavigationLink(destination: NoteEditorView(attributedText: $todoDescriptionAttr)) {
						if todoDescriptionAttr.string.isEmpty {
							Text("Tap to Add Notes")
								.foregroundColor(.secondary)
						} else if let formatted = try? AttributedString(todoDescriptionAttr) {
							Text(formatted)
						}
					}
				}
				SwiftUI.Section(header: Text("Project")) {
					NavigationLink(destination: ProjectPicker(selectedProject: $selectedProject, selectedSection: $selectedSection, inbox: $isInboxSelected)) {
						if let selectedProject = selectedProject {
							LabelView(project: selectedProject)
						} else if selectedProject == nil && isInboxSelected == true {
							Label {
								Text("Inbox")
									.foregroundStyle(Color.primary)
							} icon: {
								Image(systemName: "tray.fill")
									.font(.caption)
									.foregroundStyle(ProjectColor.blue.color)
									.frame(width: 34, height: 34)
									.background(ProjectColor.blue.color.opacity(0.2))
									.cornerRadius(10)
							}
							.padding(.vertical, 2)
						} else {
							Label {
								Text("No Project Selected")
									.foregroundStyle(Color.primary)
							} icon: {
								Image(systemName: "checkmark.circle.fill")
									.font(.caption)
									.foregroundStyle(ProjectColor.blue.color)
									.frame(width: 34, height: 34)
									.background(ProjectColor.blue.color.opacity(0.2))
									.cornerRadius(10)
							}
							.padding(.vertical, 2)
						}
					}
				}
				Button {
					createTodo()
					dismiss()
				} label: {
					Label("Create Project", systemImage: "rectangle.stack.fill.badge.plus")
				}
			}
			.navigationTitle("Create Todo")
			#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						dismiss()
					} label: {
						Label("Close", systemImage: "xmark.circle.fill")
					}
				}
			}
			#elseif os(macOS)
			.toolbar {
				ToolbarItem(placement: .navigation) {
					Button {
						dismiss()
					} label: {
						Label("Close", systemImage: "xmark.circle.fill")
					}
				}
			}
			#endif
		}
	}

	private func createTodo() {
		let newTodo = Todo(
			title: todoTitle,
			descriptionText: todoDescriptionAttr.string.isEmpty ? nil : todoDescriptionAttr.string,
			isInbox: isInboxSelected,
			dueDate: dueDate,
			deadline: deadline,
			project: selectedProject,
			section: selectedSection
		)

		modelContext.insert(newTodo)
		dismiss()
	}
}
