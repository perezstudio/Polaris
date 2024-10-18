//
//  MainMenuView.swift
//  Polaris
//
//  Created by Kevin Perez on 10/18/24.
//

import SwiftUI

struct MainMenuView: View {
    var body: some View {
		NavigationStack {
			List {
				Section {
					Label("Inbox", systemImage: "tray.fill")
				}
				Section {
					Label("Today", systemImage: "star.fill")
					Label("Upcoming", systemImage: "calendar")
					Label("All My Tasks", systemImage: "checklist")
					Label("Someday", systemImage: "archivebox.fill")
					Label("Logbook", systemImage: "checkmark.square.fill")
				}
				Section {
					Label("My Project", systemImage: "square.stack")
				}
//				ForEach(items) { item in
//					NavigationLink {
//						Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
//					} label: {
//						Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
//					}
//				}
//				.onDelete(perform: deleteItems)
			}
		}
    }
}

#Preview {
    MainMenuView()
}
