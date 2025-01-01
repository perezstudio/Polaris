//
//  MonthScrollView.swift
//  Polaris
//
//  Created by Kevin Perez on 1/1/25.
//

import SwiftUI

struct MonthScrollView: View {
	
	let months = Calendar.current.monthSymbols // ["January", "February", ..., "December"]
	
	// 1-based indexing for month selection
	@Binding var selectedMonth: Int
	
	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 12) {
				// Use 1-based indexing directly
				ForEach(1...months.count, id: \.self) { index in
					Text(months[index - 1]) // Convert to 0-based for array access
						.padding()
						.background(selectedMonth == index ? Color.blue : Color.gray.opacity(0.3))
						.foregroundColor(selectedMonth == index ? .white : .black)
						.cornerRadius(10)
						.onTapGesture {
							selectedMonth = index // Maintain 1-based indexing
						}
				}
			}
			.padding(.horizontal)
		}
		.frame(height: 60)
	}
}

#Preview {
	@Previewable @State var selectedPreviewMonth: Int = 3
	MonthScrollView(selectedMonth: $selectedPreviewMonth)
}
