//
//  ContentView.swift
//  Polaris
//
//  Created by Kevin Perez on 10/18/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
	
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass
	@Environment(GlobalStore.self) var store
	
	var body: some View {
		Group {
			if horizontalSizeClass == .compact {
				// iPhone layout - just show the sidebar
				SidebarView()
			} else {
				// iPad layout - show the full split view
				NavigationSplitView {
					SidebarView()
				} detail: {
					switch store.currentView {
					case .inbox:
						InboxView()
					case .today:
						TodayView()
					case .upcoming:
						UpcomingView()
					case .project(let project):
						if let project = project {
							ProjectDetailView(project: project)
						} else {
							ProjectsView()
						}
					case .label(let label):
						if let label = label {
							LabelDetailView(label: label)
						} else {
							Text("Labels")
						}
					case .completed:
						CompletedTasksView()
					}
				}
			}
		}
		#if os(iOS)
		.sheet(isPresented: Bindable(store).showTaskDetail) {
			if let selectedTask = store.selectedTask {
				TaskDetailView(task: selectedTask, isInSheet: true)
			}
		}
		#else
		.inspector(isPresented: Bindable(store).showTaskDetail) {
			if let selectedTask = store.selectedTask {
				TaskDetailView(task: selectedTask, isInSheet: false)
			} else {
				Text("Select a task to view details")
					.foregroundStyle(.secondary)
			}
		}
		#endif
	}
}

#Preview {
	ContentView()
        .modelContainer(for: Project.self, inMemory: true)
        .environment(GlobalStore())
}
