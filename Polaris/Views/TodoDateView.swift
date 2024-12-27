//
//  TodoDateView.swift
//  Polaris
//
//  Created by Kevin Perez on 12/26/24.
//

import SwiftUI

struct TodoDateView: View {
	
	@State var openDateSelectionSheet: Bool = false
	@Binding var showDetails: Bool
	@Binding var date: Date?
	
	private var isToday: Bool {
		guard let currentDate = date else { return false }
		return Calendar.current.isDateInToday(currentDate)
	}
	
	private var isOverdue: Bool {
		guard let currentDate = date else { return false }
		return currentDate < Date.now && !isToday
	}
	
	private var formattedDate: String {
		guard let currentDate = date else { return "" }
		let formatter = DateFormatter()
		formatter.dateFormat = "MMM d"
		return formatter.string(from: currentDate)
	}
	
	var body: some View {
		VStack {
			if date != nil {
				if isToday {
					// Today's tasks
					if (showDetails == true) {
						Button {
							openDateSelectorSheet()
						} label: {
							Label {
								Text("Today")
									.foregroundStyle(Color.primary)
							} icon: {
								Image(systemName: "star.fill")
									.foregroundStyle(Color.yellow)
							}
						}
					} else {
						Label {
							Text("Today")
								.foregroundStyle(Color.primary)
						} icon: {
							Image(systemName: "star.fill")
								.foregroundStyle(Color.yellow)
						}
						.labelStyle(.iconOnly)
					}
				} else if isOverdue {
					// Overdue tasks
					if (showDetails == true) {
						Button {
							openDateSelectorSheet()
						} label: {
							Label {
								Text(formattedDate)
							} icon: {
								Image(systemName: "circle.fill")
									.foregroundStyle(Color.red)
							}
						}
					} else {
						Label {
							Text(formattedDate)
						} icon: {
							Image(systemName: "circle.fill")
						}
						.foregroundStyle(Color.red)
					}
				} else {
					// Future tasks
					if (showDetails == true) {
						Button {
							openDateSelectorSheet()
						} label: {
							Label {
								Text(formattedDate)
							} icon: {
								Image(systemName: "calendar")
									.foregroundStyle(Color.gray)
							}
						}
					} else {
						Label {
							Text(formattedDate)
						} icon: {
							Image(systemName: "calendar")
								.foregroundStyle(Color.gray)
						}
					}
				}
			} else {
				// Show date picker or add date button when no date is set
				Button {
					date = Date.now
					openDateSelectorSheet()
				} label: {
					Image(systemName: "calendar.badge.plus")
						.foregroundStyle(Color.gray)
				}
			}
		}
		.sheet(isPresented: $openDateSelectionSheet) {
			DateSelectorSheet(date: $date)
		}
	}
	
	func openDateSelectorSheet() {
		openDateSelectionSheet.toggle()
	}
}

#Preview {
	
	@Previewable @State var details: Bool = false
	@Previewable @State var date: Date? = Date.now
	
	VStack(spacing: 20) {
		// Today's date
		TodoDateView(showDetails: .constant(false), date: .constant(Date.now))
		
		// Overdue date
		TodoDateView(showDetails: .constant(false), date: .constant(Calendar.current.date(byAdding: .day, value: -2, to: Date.now)))
		
		// Future date
		TodoDateView(showDetails: .constant(false), date: .constant(Calendar.current.date(byAdding: .day, value: 2, to: Date.now)))
		
		// No date
		TodoDateView(showDetails: .constant(false), date: .constant(nil))
	}
	.padding()
	
	TodoCard(todo: Todo(title: "Testing", notes: "testing notes", status: false, dueDate: nil, deadLineDate: Date.now, inbox: false), showDetails: $details, isNewTodo: true)
}
