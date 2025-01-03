//
//  DayScrollView.swift
//  Polaris
//
//  Created by Kevin Perez on 1/1/25.
//

import SwiftUI

struct DayScrollView: View {
	let calendar = Calendar.current
	
	// Binding for selected year, month, and day
	@Binding var selectedYear: Int
	@Binding var selectedMonth: Int
	@Binding var selectedDay: Int
	
	// Get today's date components
	private var today: (year: Int, month: Int, day: Int) {
		let today = calendar.startOfDay(for: Date())
		let year = calendar.component(.year, from: today)
		let month = calendar.component(.month, from: today)
		let day = calendar.component(.day, from: today)
		return (year, month, day)
	}
	
	// Generate weeks grouped by Sunday to Saturday
	var weeks: [[Date]] {
		// Start from the first day of the selected month and year
		let startOfMonth = calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth))!
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
							let monthNumber = calendar.component(.month, from: date)
							let yearNumber = calendar.component(.year, from: date)
							
							// Check if the day is today
							let isToday = today.year == yearNumber && today.month == monthNumber && today.day == dayNumber
							
							VStack(spacing: 8) {
								Text(dayOfWeek) // Day of the week (e.g., Sun)
									.font(.caption)
									.fontWeight(.bold)
									.foregroundColor(Color.gray.opacity(0.6))
								
								// Day number with conditional background for today
								Text("\(dayNumber)") // Day number
									.font(.title2)
									.bold()
									.foregroundColor(isToday ? Color.white : Color.primary)
									.frame(width: 38, height: 38)
									.background(
										Circle()
											.fill(isToday ? Color.red : Color.clear) // Red for today
									)
							}
							.padding()
							.background(dayNumber == selectedDay ? Color.gray.opacity(0.3) : Color.clear) // Highlight selected day
							.foregroundColor(dayNumber == selectedDay ? .white : .primary)
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
	@Previewable @State var selectedYear = Calendar.current.component(.year, from: Date())
	@Previewable @State var selectedMonth = Calendar.current.component(.month, from: Date())
	@Previewable @State var selectedDay = Calendar.current.component(.day, from: Date())
	return DayScrollView(selectedYear: $selectedYear, selectedMonth: $selectedMonth, selectedDay: $selectedDay)
}
