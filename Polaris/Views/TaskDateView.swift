//
//  TaskDateView.swift
//  Polaris
//
//  Created by Kevin Perez on 10/26/24.
//

import SwiftUI

struct TaskDateView: View {
	@State var dateType: String
	@Bindable var todo: Todo
	@State private var isDateEnabled: Bool
	@Binding var openCalendarPicker: Bool

	init(dateType: String, todo: Todo, calendarPicker: Binding<Bool>) {
		self.dateType = dateType
		self.todo = todo
		self._isDateEnabled = State(initialValue:
			dateType == "Due Date" ? todo.dueDate != nil : todo.deadLine != nil
		)
		self._openCalendarPicker = calendarPicker // Use _openCalendarPicker for @Binding
	}
	
	var iconColor: Color {
		dateType == "Due Date" ? .red : .orange
	}
	
	var iconName: String {
		dateType == "Due Date" ? "calendar" : "flag.fill"
	}
	
	var body: some View {
		VStack(spacing: 12) {
			HStack(spacing: 16) {
				ZStack {
					RoundedRectangle(cornerRadius: 6)
						.strokeBorder(iconColor,
									lineWidth: 1
						)
						.background(
							RoundedRectangle(cornerRadius: 10)
								.fill(iconColor.opacity(0.15))
						)
						.frame(width: 30, height: 30)
					
					Image(systemName: iconName)
						.font(.system(size: 16))
						.fontWeight(.semibold)
						.foregroundColor(iconColor)
				}
				Text(dateType)
				Spacer()
				Toggle("", isOn: $isDateEnabled)
					.onChange(of: isDateEnabled) { oldValue, newValue in
						if !newValue {
							// Clear the date when toggle is turned off
							if dateType == "Due Date" {
								todo.dueDate = nil
							} else {
								todo.deadLine = nil
							}
							openCalendarPicker = false  // Close calendar when toggle is off
						} else {
							// Set to current date when toggle is turned on
							if dateType == "Due Date" {
								todo.dueDate = Date()
							} else {
								todo.deadLine = Date()
							}
							openCalendarPicker = true  // Open calendar when toggle is on
						}
					}
			}
			if (isDateEnabled && openCalendarPicker) {
				DatePicker(
					"",
					selection: dateType == "Due Date"
						? Binding(
							get: { todo.dueDate ?? Date() },
							set: { todo.dueDate = $0 }
						  )
						: Binding(
							get: { todo.deadLine ?? Date() },
							set: { todo.deadLine = $0 }
						  ),
					displayedComponents: [.date]
				)
				.labelsHidden()
				.datePickerStyle(.graphical)
			}
		}
	}
}

#Preview {
	@Previewable @State var picker: Bool = false
	var newProject = Project(
		id: UUID(),
		name: "New Project",
		notes: "Description",
		status: .inProgress,
		icon: "square.stack",
		color: .red
	)
	var newTodo = Todo(
		title: "New Task",
		status: false,
		notes: "Description",
		project: newProject,
		inbox: false
	)
	
	TaskDateView(dateType: "Deadline", todo: newTodo, calendarPicker: $picker)
		.modelContainer(for: [Todo.self, Project.self], inMemory: true)
		.padding()
}
