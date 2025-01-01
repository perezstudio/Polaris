//
//  ColorPickerView.swift
//  Polaris
//
//  Created by Kevin Perez on 12/27/24.
//

import SwiftUI

struct ColorPickerView: View {
	
	@Environment(\.dismiss) var dismiss
	@Binding var selectedColor: ColorPalette
	let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 5)
	
    var body: some View {
		NavigationStack {
			ScrollView {
				LazyVGrid(columns: columns, spacing: 20) {
					ForEach(ColorPalette.allCases) { color in
						Button {
							selectedColor = color
							dismiss()
						} label: {
							Circle()
								.foregroundStyle(color.color)
								.frame(width: 50, height: 50)
								.padding(6)
								.background(
									Circle()
										.stroke(selectedColor == color ? color.color : Color.clear, lineWidth: 4)
								)
						}
					}
				}
				.padding() // Add padding around the grid
			}
			.navigationTitle("Select A Color")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button {
						dismiss()
					} label: {
						Label("Cancel", systemImage: "xmark.fill")
					}
				}
			}
		}
    }
}

#Preview {
	
	@Previewable @State var selectedColor: ColorPalette = .blue
	
	ColorPickerView(selectedColor: $selectedColor)
}
