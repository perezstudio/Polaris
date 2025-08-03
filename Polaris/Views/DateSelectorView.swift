//
//  DateSelectorView.swift
//  Polaris
//
//  Created by Kevin Perez on 5/6/25.
//

import SwiftUI
import SwiftData

struct DateSelectorView: View {
	
	@Environment(\.dismiss) var dismiss
	@Binding var selectedYear: Int
	@Binding var selectedMonth: Int
	@Binding var selectedDay: Int
	
	let years: [Int]
	let months = [
		"January", "February", "March", "April",
		"May", "June", "July", "August",
		"September", "October", "November", "December"
	]
	
	// Computed selectedDate
	private var selectedDate: Date {
		var components = DateComponents()
		components.year = selectedYear
		components.month = selectedMonth
		components.day = selectedDay
		return Calendar.current.date(from: components) ?? Date()
	}
	
	init(selectedYear: Binding<Int>, selectedMonth: Binding<Int>, selectedDay: Binding<Int>) {
		self._selectedYear = selectedYear
		self._selectedMonth = selectedMonth
		self._selectedDay = selectedDay
		
		let calendar = Calendar.current
		let currentYear = calendar.component(.year, from: Date())
		self.years = Array((currentYear - 5)...(currentYear + 10))
	}
	
	var body: some View {
		NavigationStack {
			VStack(spacing: 20) {
				
				// Year selector
				VStack(alignment: .leading) {
					Text("Year")
						.font(.subheadline)
						.foregroundColor(.secondary)
						.padding(.leading)
					
					ScrollViewReader { scrollView in
						ScrollView(.horizontal, showsIndicators: false) {
							HStack(spacing: 8) {
								ForEach(years, id: \.self) { year in
									YearButton(year: year, isSelected: year == selectedYear) {
										selectedYear = year
										validateDay()
										scrollView.scrollTo(year, anchor: .center)
									}
									.id(year)
								}
							}
							.padding(.horizontal)
						}
						.onAppear {
							scrollView.scrollTo(selectedYear, anchor: .center)
						}
					}
				}
				
				// Month selector
				VStack(alignment: .leading) {
					Text("Month")
						.font(.subheadline)
						.foregroundColor(.secondary)
						.padding(.leading)
					
					ScrollViewReader { scrollView in
						ScrollView(.horizontal, showsIndicators: false) {
							HStack(spacing: 8) {
								ForEach(0..<months.count, id: \.self) { index in
									MonthButton(
										month: months[index],
										isSelected: index + 1 == selectedMonth
									) {
										selectedMonth = index + 1
										validateDay()
										scrollView.scrollTo(index, anchor: .center)
									}
									.id(index)
								}
							}
							.padding(.horizontal)
						}
						.onAppear {
							scrollView.scrollTo(selectedMonth - 1, anchor: .center)
						}
					}
				}
				
				// Day selector
				VStack(alignment: .leading) {
					Text("Day")
						.font(.subheadline)
						.foregroundColor(.secondary)
						.padding(.leading)
					
					ScrollViewReader { scrollView in
						ScrollView(.horizontal, showsIndicators: false) {
							HStack(spacing: 8) {
								ForEach(1...daysInMonth(), id: \.self) { day in
									DayButton(
										day: day,
										dayOfWeek: dayOfWeekString(year: selectedYear, month: selectedMonth, day: day),
										isSelected: day == selectedDay
									) {
										selectedDay = day
										scrollView.scrollTo(day, anchor: .center)
									}
									.id(day)
								}
							}
							.padding(.horizontal)
						}
						.onAppear {
							scrollView.scrollTo(selectedDay, anchor: .center)
						}
					}
				}
				
				Spacer()
			}
			.navigationTitle("Select Date")
			#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
			#endif
//			.toolbar {
//				ToolbarItem(placement: .navigationBarTrailing) {
//					Button {
//						dismiss()
//					} label: {
//						Label("Done", systemImage: "xmark.circle.fill")
//					}
//				}
//			}
		}
	}
	
	private func daysInMonth() -> Int {
		let calendar = Calendar.current
		var components = DateComponents()
		components.year = selectedYear
		components.month = selectedMonth
		
		guard let date = calendar.date(from: components),
			  let range = calendar.range(of: .day, in: .month, for: date) else {
			return 30
		}
		return range.count
	}
	
	private func validateDay() {
		let maxDays = daysInMonth()
		if selectedDay > maxDays {
			selectedDay = maxDays
		}
	}
	
	private func dayOfWeekString(year: Int, month: Int, day: Int) -> String {
		let calendar = Calendar.current
		var components = DateComponents()
		components.year = year
		components.month = month
		components.day = day
		
		guard let date = calendar.date(from: components) else {
			return ""
		}
		
		let formatter = DateFormatter()
		formatter.dateFormat = "E"
		return formatter.string(from: date)
	}
}

#Preview {
	let date = Date()
	let calendar = Calendar.current
	return DateSelectorView(
		selectedYear: .constant(calendar.component(.year, from: date)),
		selectedMonth: .constant(calendar.component(.month, from: date)),
		selectedDay: .constant(calendar.component(.day, from: date))
	)
}
