//
//  ContentView.swift
//  Polaris
//
//  Created by Kevin Perez on 10/18/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
	
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass
	@Environment(GlobalStore.self) var store
	@State var showInspectorSheet: Bool = false
	
	var body: some View {
		if horizontalSizeClass == .compact {
			// iPhone layout - just show the sidebar
			SidebarView()
				.inspector(isPresented: Binding(
					get: { store.showInspector },
					set: { store.showInspector = $0 }
				)) {
					TodoInspectorView()
				}
		} else {
			// iPad layout - show the full split view
			NavigationSplitView {
				SidebarView()
			} detail: {
				Text("Test")
			}
		}
	}
}

#Preview {
	ContentView()
        .modelContainer(for: Project.self, inMemory: true)
}
