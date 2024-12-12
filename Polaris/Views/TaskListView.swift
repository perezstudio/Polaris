//
//  TaskListView.swift
//  Polaris
//
//  Created by Kevin Perez on 12/11/24.
//


// Create new file: TaskListView.swift

import SwiftUI
import SwiftData

struct TaskListView: View {
	let tasks: [(date: Date, tasks: [Todo])]
	@Binding var selectedTask: Todo?
	@Binding var openTaskDetailsInspector: Bool
	let scrollNamespace: String
	let onHeaderAppear: (Date) -> Void
	
	var body: some View {
		LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
			ForEach(tasks, id: \.date) { group in
				Section {
					if !group.tasks.isEmpty {
						ForEach(group.tasks) { todo in
							Button {
								if selectedTask == todo {
									openTaskDetailsInspector.toggle()
								} else {
									selectedTask = todo
									openTaskDetailsInspector = true
								}
							} label: {
								TaskRowView(todo: todo)
							}
							.padding(.horizontal)
						}
					} else {
						Text("No tasks scheduled")
							.foregroundStyle(.secondary)
							.padding()
					}
				} header: {
					Text(group.date.formatted(.dateTime.weekday().day().month()))
						.font(.headline)
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding()
						.background(.background)
						.id("header_\(group.date)")
						.background(
							GeometryReader { headerGeometry in
								Color.clear.preference(
									key: ScrollPositionPreferenceKey.self,
									value: [DateFrame(date: group.date, frame: headerGeometry.frame(in: .named(scrollNamespace)))]
								)
							}
						)
						.onAppear {
							onHeaderAppear(group.date)
						}
				}
			}
		}
	}
}

// End of file
