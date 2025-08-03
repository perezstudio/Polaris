//
//  NavigationRowView.swift
//  Polaris
//
//  Created by Kevin Perez on 7/11/25.
//

import SwiftUI

struct NavigationRowView<Destination: View>: View {
	let title: String
	let icon: String
	let color: Color
	let destination: () -> Destination

	@State private var isPressed: Bool = false

	var body: some View {
		NavigationLink(destination: destination()) {
			HStack(spacing: 12) {
				Image(systemName: icon)
					.foregroundStyle(color)
				Text(title)
				Spacer()
			}
			.padding()
			.background(isPressed ? Color.gray.opacity(0.2) : Color.clear)
			.cornerRadius(8)
			.contentShape(Rectangle()) // ensures entire row is tappable
		}
		.simultaneousGesture(
			DragGesture(minimumDistance: 0)
				.onChanged { _ in isPressed = true }
				.onEnded { _ in isPressed = false }
		)
	}
}

#Preview {
    NavigationRowView(title: "Projects", icon: "folder", color: .blue, destination: { ProjectsView() })
}
