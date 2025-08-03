//
//  ListSection.swift
//  Polaris
//
//  Created by Kevin Perez on 7/12/25.
//

import SwiftUI

struct ListSection<Content: View>: View {
	let title: String?
	let content: () -> Content

	init(title: String? = nil, @ViewBuilder content: @escaping () -> Content) {
		self.title = title
		self.content = content
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			if let title = title {
				Text(title.uppercased())
					.font(.caption)
					.foregroundStyle(.secondary)
					.padding(.horizontal)
					.padding(.horizontal)
			}

			VStack(spacing: 0) {
				content()
			}
			.clipShape(RoundedRectangle(cornerRadius: 12))
			.padding(.horizontal)
		}
		.padding(.vertical, 8)
	}
}
