//
//  LogbookFilterView.swift
//  Polaris
//
//  Created by Kevin Perez on 11/4/24.
//

import SwiftUI
import SwiftData

struct LogbookFilterView: View {
	
	@Query(
		filter: #Predicate<Todo> { todo in
			todo.status == true
		},
		sort: \Todo.createdDate,
		order: .reverse,
		animation: .snappy
	) private var completedTodos: [Todo]
	@State var openCreateTaskSheet: Bool = false
	@State var openTaskDetailsInspector: Bool = false
	@State var selectedTask: Todo? = nil
	
	// Create dictionary grouping based on created dates
	private var groupedTodos: [String: [Todo]] {
		Dictionary(grouping: completedTodos) { todo in
			formatDate(todo.createdDate)
		}
	}
	
	// Get sorted dates for sections
	private var sortedDates: [String] {
		groupedTodos.keys.sorted { date1, date2 in
			// Convert back to Date for proper sorting
			let formatter = DateFormatter()
			formatter.dateFormat = "MMMM d, yyyy"
			let d1 = formatter.date(from: date1) ?? Date.distantPast
			let d2 = formatter.date(from: date2) ?? Date.distantPast
			return d1 > d2
		}
	}
	
	var body: some View {
		List {
			if(sortedDates.isEmpty) {
				Section {
					ContentUnavailableView {
						Label("No Tasks", systemImage: "checkmark.square")
					} description: {
						Text("Complete a task to see it listed in your project.")
					}
				}
			} else {
				ForEach(sortedDates, id: \.self) { date in
					Section(header: Text(date)) {
						ForEach(groupedTodos[date] ?? []) { todo in
							Button {
								
							} label: {
								TaskRowView(todo: todo)
							}
						}
					}
				}
			}
		}
		.navigationTitle("Logbook")
		#if os(iOS)
		.navigationBarTitleDisplayMode(.large)
		#endif
		.inspector(isPresented: $openTaskDetailsInspector) {
			if let task = selectedTask {
				TaskDetailsView(todo: task, sheetState: $openTaskDetailsInspector)
			} else {
				ContentUnavailableView("No Task Selected",
					systemImage: "checklist")
			}
		}
		.sheet(isPresented: $openCreateTaskSheet) {
			CreateTodoView()
		}
	}
	
	private func formatDate(_ date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "MMMM d, yyyy"
		return formatter.string(from: date)
	}
	
}

#Preview {
	LogbookFilterView()
}
