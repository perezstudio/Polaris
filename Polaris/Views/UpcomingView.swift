//
//  UpcomingView.swift
//  Polaris
//
//  Created by Kevin Perez on 12/26/24.
//

import SwiftUI

struct UpcomingView: View {
    var body: some View {
		NavigationView {
			ScrollView {
				VStack {
					Text("Upcoming Todos")
				}
			}
			.navigationTitle("Upcoming")
			.navigationBarTitleDisplayMode(.inline)
		}
    }
}

#Preview {
    UpcomingView()
}
