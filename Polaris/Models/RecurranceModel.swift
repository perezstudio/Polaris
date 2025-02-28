//
//  RecurranceModel.swift
//  Polaris
//
//  Created by Kevin Perez on 2/25/25.
//

import SwiftUI
import SwiftData

enum RecurrencePattern: String, CaseIterable, Codable {
	case none = "None"
	case daily = "Daily"
	case weekdays = "Weekdays"
	case weekly = "Weekly"
	case biweekly = "Bi-Weekly"
	case monthly = "Monthly"
	case yearly = "Yearly"
	case custom = "Custom"
	
	func nextDate(from date: Date) -> Date? {
		let calendar = Calendar.current
		
		switch self {
		case .none:
			return nil
		case .daily:
			return calendar.date(byAdding: .day, value: 1, to: date)
		case .weekdays:
			// Skip to next weekday (Monday-Friday)
			var nextDate = calendar.date(byAdding: .day, value: 1, to: date)!
			let weekday = calendar.component(.weekday, from: nextDate)
			// If the next day is Saturday (7) or Sunday (1), adjust
			if weekday == 7 { // Saturday
				nextDate = calendar.date(byAdding: .day, value: 2, to: nextDate)!
			} else if weekday == 1 { // Sunday
				nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate)!
			}
			return nextDate
		case .weekly:
			return calendar.date(byAdding: .weekOfYear, value: 1, to: date)
		case .biweekly:
			return calendar.date(byAdding: .weekOfYear, value: 2, to: date)
		case .monthly:
			return calendar.date(byAdding: .month, value: 1, to: date)
		case .yearly:
			return calendar.date(byAdding: .year, value: 1, to: date)
		case .custom:
			// Custom recurrence would be handled separately with customRecurrenceData
			return nil
		}
	}
}

struct CustomRecurrence: Codable {
	var frequency: Int = 1 // How many units (e.g., 2 for every 2 weeks)
	var unit: RecurrenceUnit = .day
	var daysOfWeek: [Int]? = nil // 1 (Sunday) through 7 (Saturday)
	var dayOfMonth: Int? = nil // 1-31
	var weekOfMonth: Int? = nil // 1-5
	var monthOfYear: Int? = nil // 1-12
	
	enum RecurrenceUnit: String, Codable {
		case day
		case week
		case month
		case year
	}
}
