//
//  Enums.swift
//  Polaris
//
//  Created by Kevin Perez on 10/18/24.
//

import SwiftUI
import SwiftData


public enum Status: String, Codable, CaseIterable, Identifiable {
	case planned
	case inProgress
	case completed
	case cancelled
	
	public var id: Self { self }
	
	var name: String {
		switch self {
			case .planned: return "Planned"
			case .inProgress: return "In Progress"
			case .completed: return "Completed"
			case .cancelled: return "Cancelled"
		}
	}
}

public enum ProjectColors: String, Codable, CaseIterable, Identifiable {
	case red
	case orange
	case yellow
	case green
	case mint
	case teal
	case cyan
	case blue
	case indigo
	case purple
	case pink
	case brown
	
	public var id: Self { self }
	
	var name: String {
		switch self {
		case .red: return "Red"
		case .orange: return "Orange"
		case .yellow: return "Yellow"
		case .green: return "Green"
		case .mint: return "Mint"
		case .teal: return "Teal"
		case .cyan: return "Cyan"
		case .blue: return "Blue"
		case .indigo: return "Indigo"
		case .purple: return "Purple"
		case .pink: return "Pink"
		case .brown: return "Brown"
		}
	}
	
	var color: Color {
		switch self {
		case .red: return .red
		case .orange: return .orange
		case .yellow: return .yellow
		case .green: return .green
		case .mint: return .mint
		case .teal: return .teal
		case .cyan: return .cyan
		case .blue: return .blue
		case .indigo: return .indigo
		case .purple: return .purple
		case .pink: return .pink
		case .brown: return .brown
		}
	}
}

enum TodoFilter {
	case all
	case inbox
	case today
	case upcoming
	case completed
}
