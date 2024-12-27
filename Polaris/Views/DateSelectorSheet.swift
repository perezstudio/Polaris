//
//  DateSelectorSheet.swift
//  Polaris
//
//  Created by Kevin Perez on 12/26/24.
//

import SwiftUI

struct DateSelectorSheet: View {
	
	@Environment(\.dismiss) var dismiss
	@Binding var date: Date?
	@State private var selectedDate: Date
	
	init(date: Binding<Date?>) {
		self._date = date
		self._selectedDate = State(initialValue: date.wrappedValue ?? Date.now)
	}
	
	var body: some View {
		NavigationStack {
			VStack {
				DatePicker("", selection: $selectedDate)
					.datePickerStyle(.graphical)
				Button {
					date = nil
					dismiss()
				} label: {
					Label {
						Text("Clear Due Date")
					} icon: {
						Image(systemName: "clear")
					}
				}
			}
			.navigationTitle("Select Due Date")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button {
						dismiss()
					} label: {
						Label {
							Text("Cancel")
						} icon: {
							Image(systemName: "xmark.circle.fill")
						}
					}
				}
				
				ToolbarItem(placement: .navigationBarLeading) {
					Button {
						date = selectedDate
						dismiss()
					} label: {
						Text("Done")
					}
				}
			}
		}
	}
}

#Preview {
	
	@Previewable @State var date: Date? = .now
	
	DateSelectorSheet(date: $date)
}
