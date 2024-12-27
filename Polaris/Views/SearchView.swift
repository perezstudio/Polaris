//
//  SearchView.swift
//  Polaris
//
//  Created by Kevin Perez on 12/26/24.
//

import SwiftUI

struct SearchView: View {
    var body: some View {
		NavigationStack {
			ScrollView {
				VStack {
					Text("Search View")
				}
			}
			.navigationTitle("Search")
			.navigationBarTitleDisplayMode(.large)
		}
    }
}

#Preview {
    SearchView()
}
