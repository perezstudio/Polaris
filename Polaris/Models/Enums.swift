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
	
	public var id: Self { self }
	
	var name: String {
		switch self {
		case .red: return "Red"
		case .orange: return "Orange"
		case .yellow: return "Yellow"
		}
	}
	
	var color: Color {
		switch self {
		case .red: return .red
		case .orange: return .orange
		case .yellow: return .yellow
		}
	}
}
