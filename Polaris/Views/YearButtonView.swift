//
//  YearButtonView.swift
//  Polaris
//
//  Created by Kevin Perez on 5/6/25.
//

import SwiftUI
import SwiftData

struct YearButton: View {
	let year: Int
	let isSelected: Bool
	let action: () -> Void
	
	var body: some View {
		Button(action: action) {
			Text(String(year))
				.padding(.vertical, 10)
				.padding(.horizontal, 15)
				.background(isSelected ? Color.blue : Color.gray.opacity(0.2))
				.foregroundColor(isSelected ? .white : .primary)
				.cornerRadius(10)
		}
	}
}

#Preview {
	YearButton(year: 2024, isSelected: false, action: {})
}
