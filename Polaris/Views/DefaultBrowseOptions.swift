//
//  DefaultBrowseOptions.swift
//  Polaris
//
//  Created by Kevin Perez on 12/26/24.
//

import SwiftUI

struct DefaultBrowseOptions: View {
    var body: some View {
		VStack {
			VStack {
				NavigationLink(destination: CompletedView()) {
					MenuItem(icon: "checkmark.circle.fill", title: "Completed", color: Color.green)
				}
			}
			.background(Color(.secondarySystemGroupedBackground))
			.cornerRadius(12)
		}
		.padding(.horizontal, 16)
    }
}

#Preview {
    DefaultBrowseOptions()
}
