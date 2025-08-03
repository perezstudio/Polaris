//
//  ProjectIconPicker.swift
//  Polaris
//
//  Created by Kevin Perez on 4/29/25.
//

import SwiftUI
import SwiftData

struct ProjectIconPicker: View {
	
	@Environment(\.dismiss) var dismiss
	
	let columns = [GridItem(.adaptive(minimum: 40), spacing: 16)]
	let categories: [IconCategory] = iconCategories

	@Binding var selectedSymbol: String
	@Binding var selectedColor: ProjectColor
	
	var body: some View {
		NavigationStack {
			ScrollView {
				LazyVStack(alignment: .leading, spacing: 32) {
					ForEach(categories) { category in
						VStack(alignment: .leading, spacing: 8) {
							Text(category.name.uppercased())
								.font(.caption)
								.foregroundStyle(Color.primary.opacity(0.5))
								.padding(.horizontal)
							LazyVGrid(columns: columns, spacing: 16) {
								ForEach(category.symbols, id: \.self) { symbol in
									Button(action: {
										selectedSymbol = symbol
										dismiss()
									}) {
										Image(systemName: symbol)
											.font(.system(size: 24))
											.frame(width: 44, height: 44)
											.foregroundStyle(selectedColor.color)
											.background(selectedSymbol == symbol ? selectedColor.color.opacity(0.2) : Color.gray.opacity(0.1))
											.clipShape(RoundedRectangle(cornerRadius: 8))
									}
									.buttonStyle(PlainButtonStyle())
								}
							}
						}
						.padding(.horizontal)
					}
				}
				.padding(.top)
			}
			.navigationTitle("Select An Icon")
			#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
			#endif
		}
	}
}

#Preview {
	
	@Previewable @State var selectedSymbol: String = "rectangle.stack.fill"
	@Previewable @State var selectedColor: ProjectColor = ProjectColor.blue
	ProjectIconPicker(selectedSymbol: $selectedSymbol, selectedColor: $selectedColor)
}
