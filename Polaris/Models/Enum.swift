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
