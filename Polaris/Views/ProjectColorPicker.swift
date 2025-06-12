//
//  ProjectColorPicker.swift
//  Polaris
//
//  Created by Kevin Perez on 4/29/25.
//

import SwiftUI
import SwiftData

struct ProjectColorPicker: View {
	
	@Environment(\.dismiss) var dismiss
	@Binding var selectedColor: ProjectColor
	let columns = [GridItem(.adaptive(minimum: 60), spacing: 24)]
	
	var body: some View {
		NavigationStack {
			ScrollView {
				LazyVGrid(columns: columns, spacing: 24) {
					ForEach(ProjectColor.allCases, id: \.self) { color in
						Button(action: {
							selectedColor = color
							dismiss()
						}) {
							ZStack {
								Circle()
									.foregroundStyle(color.color)
								Image(systemName: "checkmark")
									.foregroundStyle(selectedColor == color ? Color.white : Color.clear)
									.fontWeight(.bold)
									.font(.title2)
							}
						}
						.buttonStyle(PlainButtonStyle())
					}
				}
				.padding()
			}
			.navigationTitle("Select A Color")
			#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
			#endif
		}
	}
}

#Preview {
	@Previewable @State var selectedColor: ProjectColor = .blue
	
	ProjectColorPicker(selectedColor: $selectedColor)
}
