//
//  CalendarDayView.swift
//  Polaris
//
//  Created by Kevin Perez on 12/11/24.
//


// Create new file: CalendarViews.swift

import SwiftUI

struct CalendarDayView: View {
	let date: Date
	let isSelected: Bool
	
	private var isToday: Bool {
		Calendar.current.isDateInToday(date)
	}
	
	var body: some View {
		VStack {
			Text(date.formatted(.dateTime.weekday(.abbreviated)))
				.font(.caption)
				.foregroundStyle(.secondary)
			Text(date.formatted(.dateTime.day()))
				.font(.headline)
		}
		.frame(width: 40, height: 60)
		.background(
			RoundedRectangle(cornerRadius: 8)
				.fill(isSelected ? Color.accentColor : Color.clear)
		)
		.overlay {
			if isToday {
				Circle()
					.stroke(Color.accentColor, lineWidth: 1)
					.frame(width: 32, height: 32)
					.offset(y: 8)
			}
		}
	}
}

struct CalendarWeekView: View {
	let dates: [Date]
	let selectedDate: Date
	let onDateSelected: (Date) -> Void
	
	var body: some View {
		HStack(spacing: 8) {
			ForEach(dates, id: \.self) { date in
				CalendarDayView(date: date, isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate))
					.onTapGesture {
						withAnimation {
							onDateSelected(date)
						}
					}
			}
		}
		.padding(.horizontal)
	}
}

// End of file
