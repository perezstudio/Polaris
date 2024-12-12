//
//  ProjectPickerView.swift
//  Polaris
//
//  Created by Kevin Perez on 10/26/24.
//

import SwiftUI
import SwiftData

struct ProjectPickerView: View {
	
	@Environment(\.dismiss) var dismiss
	@Query var projects: [Project]
	
    var body: some View {
		NavigationStack {
			List {
				Section {
					Text("No Project")
					Text("Inbox")
				}
				Section {
					if(projects.isEmpty) {
						ContentUnavailableView {
							Label("No Available Projects", systemImage: "rectangle.stack")
						}
					} else {
						ForEach(projects, id: \.id) { project in
							ProjectRowView(project: project)
						}
					}
				}
			}
			.navigationTitle("Select A Project")
			#if os(iOS)
			.navigationBarTitleDisplayMode(.large)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						print("Done")
						dismiss()
					} label: {
						Label("Done", systemImage: "checkmark.circle")
							.labelStyle(.titleOnly)
					}
				}
				ToolbarItem(placement: .cancellationAction) {
					Button {
						print("Cancel")
						dismiss()
					} label: {
						Label("Cancel", systemImage: "xmark.circle.fill")
							.labelStyle(.titleOnly)
					}
				}
			}
			#endif
		}
    }
}

#Preview {
    ProjectPickerView()
}
