//
//  YearScrollView.swift
//  Polaris
//
//  Created by Kevin Perez on 1/1/25.
//

import SwiftUI

struct YearScrollView: View {
	
	// Generate years: -5 to +10 from the current year
	let years: [Int] = {
		let currentYear = Calendar.current.component(.year, from: Date())
		return Array((currentYear - 5)...(currentYear + 10))
	}()
	
	// Binding for the selected year
	@Binding var selectedYear: Int
	
	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 12) {
				ForEach(years, id: \.self) { year in
					Text(String(year)) // Force plain string conversion (no commas)
						.font(.body) // Optional: Adjust font style if needed
						.padding(.vertical, 8)
						.padding(.horizontal, 16)
						.background(selectedYear == year ? Color.gray.opacity(0.3) : Color.clear)
						.foregroundColor(Color.primary)
						.cornerRadius(10)
						.onTapGesture {
							selectedYear = year // Update the selected year
						}
				}
			}
			.padding(.horizontal)
		}
	}
}

#Preview {
	@Previewable @State var selectedPreviewYear: Int = Calendar.current.component(.year, from: Date())
	YearScrollView(selectedYear: $selectedPreviewYear)
}
