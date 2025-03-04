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
		HStack(spacing: 8) {
			CheckMarkView(todoStatus: $todo.status)
			if todo.dueDate != nil {
				TodoDateView(showDetails: $showDetails, date: $todo.dueDate)
			}
			if todo.title.isEmpty {
				Text(todo.title)
					.multilineTextAlignment(.leading)
					.lineLimit(1)
					.truncationMode(.tail)
			}
		}
		.background(Rectangle().fill(Color(UIColor.secondarySystemGroupedBackground)))
		.frame(maxWidth: .infinity, alignment: .leading)
		.contentShape(Rectangle())
	}
}

#Preview {
	
	@Previewable @State var details: Bool = true
	
	TodoCard(todo: Todo(title: "Testing", notes: "testing notes", status: false, dueDate: Date.now, deadLineDate: nil, inbox: false), showDetails: $details, isNewTodo: true)
}
