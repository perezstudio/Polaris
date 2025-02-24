//
//  Enums.swift
//  Polaris
//
//  Created by Kevin Perez on 10/18/24.
//

import SwiftUI

enum Status: String, CaseIterable, Codable {
	case Backlog = "Backlog"
	case InProgress = "In Progress"
	case Completed = "Completed"
	case Cancelled = "Cancelled"
	case Archived = "Archived"
}

enum ColorPalette: String, CaseIterable, Codable, Identifiable {
	case red = "Red"
	case orange = "Orange"
	case yellow = "Yellow"
	case green = "Green"
	case blue = "Blue"
	case purple = "Purple"
	
	var id: UUID { UUID() }
	
	var color: Color {
		switch self {
		case .red: return .red
		case .orange: return .orange
		case .yellow: return .yellow
		case .green: return .green
		case .blue: return .blue
		case .purple: return .purple
		}
	}
}

enum FocusedField {
	case title, notes
}

