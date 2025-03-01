//
//  TodoCard.swift
//  Polaris
//
//  Created by Kevin Perez on 12/26/24.
//

import SwiftUI
import SwiftData

struct TodoCard: View {
	
	@Environment(\.modelContext) private var modelContext
	@Bindable var todo: Todo
	@Binding var showDetails: Bool
	@FocusState private var focusedField: FocusedField?
	var isNewTodo: Bool
	@State private var showRecurrenceSheet = false
	
	var body: some View {
		if showDetails == true {
			// Active Task
			VStack(alignment: .leading, spacing: 20) {
				HStack {
					CheckMarkView(todoStatus: $todo.status)
						.onChange(of: todo.status) { _, isCompleted in
								if isCompleted && todo.isRecurring {
									// When a recurring todo is completed, generate the next instance
									DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
										_ = todo.generateNextOccurrence(modelContext: modelContext)
										try? modelContext.save()
									}
								}
							}
					TextField("New To Do", text: $todo.title, axis: .vertical)
						.focused($focusedField, equals: .title)
				}
				HStack {
					TextField("Notes", text: $todo.notes, axis: .vertical)
						.focused($focusedField, equals: .notes)
						.frame(maxWidth: .infinity, alignment: .leading)
				}
				.frame(maxWidth: .infinity)
				.clipped()
				HStack {
					TodoDateView(showDetails: $showDetails, date: $todo.dueDate)
					Spacer()
										
					// Recurrence button
					Button {
						showRecurrenceSheet = true
					} label: {
						Label {
							Text(todo.isRecurring ? todo.recurrencePatternEnum.rawValue : "")
						} icon: {
							Image(systemName: todo.isRecurring ? "repeat" : "repeat.circle")
						}
						.foregroundColor(todo.isRecurring ? .blue : .gray)
					}
				}
			}
			.padding(.horizontal, 16)
			.padding(.vertical, 16)
			.frame(maxWidth: .infinity, alignment: .leading)
			.clipped()
			.background {
				#if os(iOS)
				RoundedRectangle(cornerRadius: 4, style: .continuous)
					.fill(Color(UIColor.secondarySystemGroupedBackground))
				#else
				RoundedRectangle(cornerRadius: 4, style: .continuous)
					.fill(.thickMaterial)
				#endif
			}
			.mask { RoundedRectangle(cornerRadius: 12, style: .continuous) }
			.onAppear {
				if isNewTodo {
					focusedField = .title
				}
			}
			.sheet(isPresented: $showRecurrenceSheet) {
				RecurrenceSelectorView(todo: todo)
			}
		} else {
			// Closed Task
			HStack(spacing: 8) {
				CheckMarkView(todoStatus: $todo.status)
				if todo.dueDate != nil {
					TodoDateView(showDetails: $showDetails, date: $todo.dueDate)
				}
				Text(todo.title)
					.multilineTextAlignment(.leading)
					.lineLimit(1)
					.truncationMode(.tail)
			}
			.padding(.horizontal, 32)
			.padding(.vertical, 16)
			.frame(maxWidth: .infinity, alignment: .leading)
		}
	}
}

#Preview {
	
	@Previewable @State var details: Bool = true
	
	TodoCard(todo: Todo(title: "Testing", notes: "testing notes", status: false, dueDate: Date.now, deadLineDate: nil, inbox: false), showDetails: $details, isNewTodo: true)
}
