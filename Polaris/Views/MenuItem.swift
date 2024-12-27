//
//  MenuItem.swift
//  Polaris
//
//  Created by Kevin Perez on 12/23/24.
//

import SwiftUI
import SwiftData

struct MenuItem: View {
	
	var icon: String
	var title: String
	var color: Color
	
	var body: some View {
		HStack {
			Label(title: {
				Text(title)
					.foregroundStyle(Color.primary)
			}, icon: {
				Image(systemName: icon)
					.foregroundStyle(color)
			})
				.font(.body)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.clipped()
		.padding(.vertical)
		.padding(.horizontal, 16)
	}
}

#Preview {
	
	MenuItem(icon: "tray.fill", title: "Inbox", color: Color.blue)
}
