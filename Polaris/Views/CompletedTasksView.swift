//
//  CompletedTasksView.swift
//  Polaris
//
//  Created by Kevin Perez on 8/3/25.
//

import SwiftUI
import SwiftData

struct CompletedTasksView: View {
	@Environment(\.modelContext) private var modelContext
	
	@Query(filter: #Predicate<Task> { $0.isCompleted })
	private var completedTasks: [Task]
	
	var sortedTasks: [Task] {
		completedTasks.sorted { $0.completedAt! > $1.completedAt! }
	}
	
	var body: some View {
		List {
			if sortedTasks.isEmpty {
				ContentUnavailableView {
					SwiftUI.Label("No completed tasks", systemImage: "checkmark.circle")
				} description: {
					Text("Completed tasks will appear here")
				}
			} else {
				ForEach(sortedTasks) { task in
					TaskRowView(task: task)
						.opacity(0.7)
				}
			}
		}
		.navigationTitle("Completed")
	}
}

#Preview {
	CompletedTasksView()
		.modelContainer(for: Task.self, inMemory: true)
}