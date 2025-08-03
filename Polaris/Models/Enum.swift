//
//  Enum.swift
//  Polaris
//
//  Created by Kevin Perez on 4/25/25.
//

import SwiftUI
import SwiftData

enum ProjectColor: String, Codable, CaseIterable, Hashable {
	case blue = "blue"
	case red = "red"
	case green = "green"
	case orange = "orange"
	case purple = "purple"
	case yellow = "yellow"
	case teal = "teal"
	case pink = "pink"
	
	var name: String {
		switch self {
		case .blue: return "Blue"
		case .red: return "Red"
		case .green: return "Green"
		case .orange: return "Orange"
		case .purple: return "Purple"
		case .yellow: return "Yellow"
		case .teal: return "Teal"
		case .pink: return "Pink"
		}
	}
	
	var icon: String {
		switch self {
		case .blue: return "circle.fill"
		case .red: return "circle.fill"
		case .green: return "circle.fill"
		case .orange: return "circle.fill"
		case .purple: return "circle.fill"
		case .yellow: return "circle.fill"
		case .teal: return "circle.fill"
		case .pink: return "circle.fill"
		}
	}
	
	var color: Color {
		switch self {
		case .blue: return .blue
		case .red: return .red
		case .green: return .green
		case .orange: return .orange
		case .purple: return .purple
		case .yellow: return .yellow
		case .teal: return .teal
		case .pink: return .pink
		}
	}
}

enum Status: String, Codable, CaseIterable, Hashable {
	case backlog
	case planned
	case inProgress
	case completed
	case cancelled
	
	var name : String {
		switch self {
		case .backlog: return "Backlog"
		case .planned: return "Planned"
		case .inProgress: return "In Progress"
		case .completed: return "Completed"
		case .cancelled: return "Cancelled"
		}
	}
	
	var icon : String {
		switch self {
		case .backlog: return "folder.fill"
		case .planned: return "calendar.badge.plus"
		case .inProgress: return "arrow.triangle.2.circlepath.fill"
		case .completed: return "checkmark.circle.fill"
		case .cancelled: return "xmark.circle.fill"
		}
	}
	
	var color : Color {
		switch self {
		case .backlog: return .blue
		case .planned: return .yellow
		case .inProgress: return .orange
		case .completed: return .green
		case .cancelled: return .red
		}
	}
}

enum TaskPriority: Int, Codable, CaseIterable, Hashable {
	case none = 0
	case low = 1
	case medium = 2
	case high = 3
	case urgent = 4
	
	var name: String {
		switch self {
		case .none: return "None"
		case .low: return "Low"
		case .medium: return "Medium"
		case .high: return "High"
		case .urgent: return "Urgent"
		}
	}
	
	var icon: String {
		switch self {
		case .none: return "circle"
		case .low: return "flag.fill"
		case .medium: return "flag.fill"
		case .high: return "flag.fill"
		case .urgent: return "flag.fill"
		}
	}
	
	var color: Color {
		switch self {
		case .none: return .gray
		case .low: return .blue
		case .medium: return .yellow
		case .high: return .orange
		case .urgent: return .red
		}
	}
	
	var sortOrder: Int {
		rawValue
	}
}
