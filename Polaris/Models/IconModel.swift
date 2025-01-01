//
//  IconModel.swift
//  Polaris
//
//  Created by Kevin Perez on 12/27/24.
//

import SwiftUI

// Define the icon group structure
struct IconGroup: Identifiable {
	let id = UUID()
	let name: String
	let symbols: [String]
}

// Sample Data
let iconGroups: [IconGroup] = [
	IconGroup(name: "Communication", symbols: ["message", "phone", "envelope", "microphone", "square.stack.fill"]),
	IconGroup(name: "Transport", symbols: ["car", "bus", "airplane"]),
	IconGroup(name: "Weather", symbols: ["cloud", "sun.max", "wind"]),
	IconGroup(name: "Nature", symbols: ["leaf", "flame", "tree"])
]
