//
//  CreateTodoView.swift
//  Polaris
//
//  Created by Kevin Perez on 10/18/24.
//

import SwiftUI
import SwiftData

// Add this enum before the CreateTodoView struct
enum Field: Hashable {
	case title
	case notes
	case none
}

struct CreateTodoView: View {
	@Environment(\.modelContext) var modelContext
	@Environment(\.dismiss) var dismiss
	@Query(sort: \Project.name) private var projects: [Project]
	@State var title: String = ""
	@State var notes: String = ""
	@State var enableDueDate: Bool = false
	@State var dueDate: Date = Date.now
	@State var enableDeadline: Bool = false
	@State var dateLine: Date = Date.now
	@State var inbox: Bool = false
	@Binding var project: Project?
	@State private var selectedProject: Project?
	// Replace existing focus state with this
	@FocusState private var focusedField: Field?

	init(project: Binding<Project?> = .constant(nil)) {
		_project = project
		_selectedProject = State(initialValue: project.wrappedValue)
		// Set inbox to true by default if no project is provided
		_inbox = State(initialValue: project.wrappedValue == nil)
	}
	
	var body: some View {
		NavigationStack {
			Form {
				Section {
					TextField("Task Title", text: $title)
						.focused($focusedField, equals: .title)
				}
				Section {
					Toggle("Enable Due Date", isOn: $enableDueDate)
					if(enableDueDate) {
						DatePicker("Due Date", selection: $dueDate)
					}
					Toggle("Enable Deadline", isOn: $enableDeadline)
					if(enableDeadline) {
						DatePicker("Date Line", selection: $dateLine)
					}
				}
				Section(header: Text("Project")) {
					NavigationLink {
						ProjectSelectionView(
							selectedProject: $selectedProject,
							inbox: $inbox
						)
						.navigationTitle("Select Project")
					} label: {
						HStack {
							if inbox {
								HStack(spacing: 10) {
									ZStack {
										RoundedRectangle(cornerRadius: 6)
											.strokeBorder(Color.blue,
												lineWidth: 1
											)
											.background(
												RoundedRectangle(cornerRadius: 10)
													.fill(Color.blue.opacity(0.15))
											)
											.frame(width: 30, height: 30)
										
										Image(systemName: "tray")
											.font(.system(size: 16))
											.fontWeight(.semibold)
											.foregroundColor(Color.blue)
									}
									Text("Inbox")
								}
								.padding(.vertical, 4)
							} else if let project = selectedProject {
								ProjectRowView(project: project)
							} else {
								HStack(spacing: 10) {
									ZStack {
										RoundedRectangle(cornerRadius: 6)
											.strokeBorder(Color.blue,
												lineWidth: 1
											)
											.background(
												RoundedRectangle(cornerRadius: 10)
													.fill(Color.blue.opacity(0.15))
											)
											.frame(width: 30, height: 30)
										
										Image(systemName: "xmark.square")
											.font(.system(size: 16))
											.fontWeight(.semibold)
											.foregroundColor(Color.blue)
									}
									Text("No Project")
								}
								.padding(.vertical, 4)
							}
							Spacer()
						}
					}
				}
				Section(header: Text("Notes")) {
					TextEditor(text: $notes)
						.focused($focusedField, equals: .notes)
						.padding(.vertical, 8)
				}
			}
			.safeAreaInset(edge: .bottom) {
				HStack {
					if focusedField != nil { // Update keyboard check
						Button {
							focusedField = nil // Dismiss keyboard
						} label: {
							Label("Dismiss Keyboard", systemImage: "keyboard.chevron.compact.down")
								.labelStyle(.iconOnly)
						}
					}
					Spacer()
					Button {
						createTodo()
					} label: {
						Label("Create Todo", systemImage: "plus.square")
					}
				}
				.padding()
				.background(.bar)
			}
			.toolbar {
				#if os(iOS)
				ToolbarItem(placement: .navigationBarTrailing) {
					Button {
						dismiss()
					} label: {
						Label("Close", systemImage: "xmark.circle.fill")
					}
				}
				#endif
			}
			.onAppear {
				focusedField = .title // Update initial focus
			}
		}
	}
	
	private func createTodo() {
		if(inbox) {
			let newTodo = Todo(
				title: title,
				status: false,
				notes: notes,
				dueDate: enableDueDate ? dueDate : nil,
				deadLine: enableDeadline ? dateLine : nil,
				project: nil,
				inbox: inbox
			)
			modelContext.insert(newTodo)
		} else {
			let newTodo = Todo(
				title: title,
				status: false,
				notes: notes,
				dueDate: enableDueDate ? dueDate : nil,
				deadLine: enableDeadline ? dateLine : nil,
				project: selectedProject,
				inbox: inbox
			)
			modelContext.insert(newTodo)
			if let selectedProject = selectedProject {
				selectedProject.todos.append(newTodo)
			}
		}
		try? modelContext.save()
		project = selectedProject
		dismiss()
	}
}

#Preview {
	CreateTodoView()
		.modelContainer(for: Project.self, inMemory: true)
}
