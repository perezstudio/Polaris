//
//  GlobalStore.swift
//  Polaris
//
//  Created by Kevin Perez on 5/26/25.
//

import Foundation
import Observation

@Observable
class GlobalStore {
	var selectedTask: Task? = nil
	var selectedProject: Project? = nil
	var showTaskDetail: Bool = false
	var currentView: TodoistView = .today
	
	func selectTask(_ task: Task?) {
		selectedTask = task
		showTaskDetail = task != nil
	}
	
	func selectProject(_ project: Project?) {
		selectedProject = project
		currentView = .project(project)
	}
	
	func closeTaskDetail() {
		showTaskDetail = false
		selectedTask = nil
	}
	
	func navigateTo(_ view: TodoistView) {
		currentView = view
	}
}

enum TodoistView: Equatable {
	case inbox
	case today
	case upcoming
	case project(Project?)
	case label(TaskLabelModel?)
	case completed
	
	var title: String {
		switch self {
		case .inbox: return "Inbox"
		case .today: return "Today"
		case .upcoming: return "Upcoming"
		case .project(let project): return project?.name ?? "Project"
		case .label(let label): return label?.name ?? "Label"
		case .completed: return "Completed"
		}
	}
}
