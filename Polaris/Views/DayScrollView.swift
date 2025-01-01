//
//  DayScrollView.swift
//  Polaris
//
//  Created by Kevin Perez on 1/1/25.
//

import SwiftUI

struct DayScrollView: View {
	let calendar = Calendar.current
	
	// Binding for selected month (1 = January, 12 = December)
	@Binding var selectedMonth: Int
	
	// Track the selected day as an integer (day of the month)
	@Binding var selectedDay: Int
	
	// Generate weeks grouped by Sunday to Saturday
	var weeks: [[Date]] {
		let today = calendar.startOfDay(for: Date())
		let currentYear = calendar.component(.year, from: today)
		
		// Start from the first day of the selected month
		let startOfMonth = calendar.date(from: DateComponents(year: currentYear, month: selectedMonth))!
		let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
		
		// Generate dates for the selected month only
		let allDates = range.compactMap { day -> Date? in
			calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
		}
		
		// Group dates into weeks (Sunday to Saturday)
		var groupedWeeks: [[Date]] = []
		var currentWeek: [Date] = []
		
		for date in allDates {
			let weekday = calendar.component(.weekday, from: date)
			
			// Start a new week if it's Sunday and the current week is not empty
			if weekday == 1 && !currentWeek.isEmpty {
				groupedWeeks.append(currentWeek)
				currentWeek = []
			}
			
			// Add the current date to the week
			currentWeek.append(date)
		}
		
		// Add the last week if it has remaining days
		if !currentWeek.isEmpty {
			groupedWeeks.append(currentWeek)
		}
		
		return groupedWeeks
	}
	
	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 20) {
				ForEach(weeks, id: \.self) { week in
					HStack(spacing: 8) {
						ForEach(week, id: \.self) { date in
							let dayNumber = calendar.component(.day, from: date)
							let dayOfWeek = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
							
							VStack {
								Text(dayOfWeek) // Day of the week (e.g., Sun)
									.font(.caption)
									.foregroundColor(.gray)
								
								Text("\(dayNumber)") // Day number
									.font(.title2)
									.bold()
							}
							.padding()
							.frame(width: 60, height: 80)
							.background(dayNumber == selectedDay ? Color.blue : Color.gray.opacity(0.1))
							.foregroundColor(dayNumber == selectedDay ? .white : .black)
							.cornerRadius(10)
							.onTapGesture {
								selectedDay = dayNumber
							}
						}
					}
				}
			}
			.padding(.horizontal)
		}
	}
}

#Preview {
	@Previewable @State var selectedMonth = 3
	@Previewable @State var selectedDay = 20
	return DayScrollView(selectedMonth: $selectedMonth, selectedDay: $selectedDay)
}
