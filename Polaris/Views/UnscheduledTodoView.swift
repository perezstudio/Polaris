//
//  UnscheduledTodoView.swift
//  Polaris
//
//  Created by Kevin Perez on 12/27/24.
//

import SwiftUI
import SwiftData

struct UnscheduledTodoView: View {
	
	@Environment(\.dismiss) var dismiss
	@Query(sort: \Todo.created, order: .forward) var unscheduledTodos: [Todo]
	
    var body: some View {
		NavigationStack {
			ScrollView {
				VStack {
					if (!unscheduledTodos.isEmpty) {
						ForEach(unscheduledTodos) { todo in
							Text(todo.title)
						}
					} else {
						ContentUnavailableView {
							Label {
								Text("No Unscheduled Todos")
							} icon: {
								Image(systemName: "calendar.badge.clock")
									.foregroundStyle(Color.red)
							}
						} description: {
							Text("There are no unscheduled todos. You're all caught up!")
						}
					}
				}
			}
			.navigationTitle("Unscheduled")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button {
						dismiss()
					} label: {
						Text("Done")
					}
				}
			}
		}
    }
}

#Preview {
    UnscheduledTodoView()
}
