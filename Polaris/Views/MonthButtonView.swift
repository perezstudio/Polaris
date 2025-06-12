//
//  MonthButtonView.swift
//  Polaris
//
//  Created by Kevin Perez on 5/6/25.
//

import SwiftUI
import SwiftData

struct MonthButton: View {
	let month: String
	let isSelected: Bool
	let action: () -> Void
	
	var body: some View {
		Button(action: action) {
			Text(month)
				.padding(.vertical, 10)
				.padding(.horizontal, 15)
				.background(isSelected ? Color.blue : Color.gray.opacity(0.2))
				.foregroundColor(isSelected ? .white : .primary)
				.cornerRadius(10)
		}
	}
}

#Preview {
	MonthButton(month: "May", isSelected: true, action: { })
	
}
