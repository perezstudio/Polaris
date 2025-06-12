//
//  DayButtonView.swift
//  Polaris
//
//  Created by Kevin Perez on 5/6/25.
//

import SwiftUI
import SwiftData

struct DayButton: View {
	let day: Int
	let dayOfWeek: String
	let isSelected: Bool
	let action: () -> Void
	
	var body: some View {
		Button(action: action) {
			VStack {
				Text("\(day)")
					.font(.headline)
				Text(dayOfWeek)
					.font(.caption)
			}
			.padding(.vertical, 10)
			.padding(.horizontal, 15)
			.frame(minWidth: 60)
			.background(isSelected ? Color.blue : Color.gray.opacity(0.2))
			.foregroundColor(isSelected ? .white : .primary)
			.cornerRadius(10)
		}
	}
}

#Preview {
	DayButton(day: 1, dayOfWeek: "Monday", isSelected: true) { }
	
}
