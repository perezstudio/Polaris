//
//  TaskDetailsView.swift
//  Polaris
//
//  Created by Kevin Perez on 10/24/24.
//

import SwiftUI

struct TaskDetailsView: View {
	
	@Bindable var todo: Todo
	@Binding var sheetState: Bool
	@State var openProjectPickerSheet: Bool = false
	@State var dueDatePicker: Bool = false
	@State var deadLinePicker: Bool = false
	@Environment(\.presentationMode) private var presentationMode
	@Environment(\.modelContext) private var modelContext
	@State private var showDeleteConfirmation = false
	
	var body: some View {
		NavigationStack {
			List {
				Section {
					HStack(alignment: .top, spacing: 16) {
						TodoCheckboxView(isChecked: $todo.status)
							.padding(.top, 4)
						TextField("", text: $todo.title, axis: .vertical)
							.fontWeight(.semibold)
							.frame(maxWidth: .infinity, alignment: .topLeading)
							.scrollContentBackground(.hidden)
							.padding(.top, 4)
					}
					.frame(alignment: .topLeading)
					.padding(.vertical, 8)
				}
				Section(header: Text("Project")) {
					Button {
						openProjectPickerSheet.toggle()
					} label: {
						if todo.inbox {
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
						} else if let project = todo.project {
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
					}
					.foregroundStyle(.primary)
				}
				Section(header: Text("Dates")) {
					Button {
						dueDatePicker.toggle()
					} label: {
						TaskDateView(dateType: "Due Date", todo: todo, calendarPicker: $dueDatePicker)
					}
					.foregroundStyle(.primary)
					Button {
						deadLinePicker.toggle()
					} label: {
						TaskDateView(dateType: "Deadline", todo: todo, calendarPicker: $deadLinePicker)
					}
					.foregroundStyle(.primary)
				}
				Section(header: Text("Notes")) {
					TextEditor(text: $todo.notes)
						.padding(.vertical, 8)
				}
			}
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Menu {
						Button {
							let duplicate = Todo(
								title: todo.title,
								status: false,
								notes: todo.notes,
								dueDate: todo.dueDate,
								deadLine: todo.deadLine,
								project: todo.project,
								inbox: todo.inbox
							)
							modelContext.insert(duplicate)
							if let project = todo.project {
								project.todos.append(duplicate)
							}
							presentationMode.wrappedValue.dismiss()
						} label: {
							Label("Duplicate Task", systemImage: "plus.square.on.square")
						}
						
						Button(role: .destructive) {
							showDeleteConfirmation = true
						} label: {
							Label("Delete Task", systemImage: "trash")
						}
					} label: {
						Label("Task Options", systemImage: "ellipsis.circle")
					}
				}
				ToolbarItem(placement: .navigationBarTrailing) {
					Button {
						sheetState.toggle()
					} label: {
						Label("Close", systemImage: "xmark.circle.fill")
					}
				}
			}
			.alert("Delete Task?", isPresented: $showDeleteConfirmation) {
				Button("Cancel", role: .cancel) {}
				Button("Delete", role: .destructive) {
					if let project = todo.project {
						project.todos.removeAll { $0.id == todo.id }
					}
					modelContext.delete(todo)
					presentationMode.wrappedValue.dismiss()
				}
			} message: {
				Text("This action cannot be undone.")
			}
			.sheet(isPresented: $openProjectPickerSheet) {
				ProjectPickerView()
			}
		}
	}
}

//#Preview {
//	
//	let newProject = Project(id: UUID(), name: "New Project", notes: "Description", status: .inProgress, icon: "square.stack", color: ProjectColors.red)
//	let newTodo = Todo(title: "New Task fasdfas fasdfasdfasdf asdf dfas dfasdf asd asdf sdsd fadfsdf  asdfads fadf sdfasdf ad ", status: false, notes: "Description", project: newProject, inbox: false)
//	
//	TaskDetailsView(todo: newTodo, sheetState: true)
//		.modelContainer(for: [Todo.self, Project.self], inMemory: true)
//}
