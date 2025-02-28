//
//  SymbolGridView.swift
//  Polaris
//
//  Created by Kevin Perez on 12/27/24.
//
import SwiftUI

struct SymbolGridView: View {
	
	@Environment(\.dismiss) var dismiss
    @State private var selectedGroup: String? = nil
	@Binding var projectIcon: String
    
    var body: some View {
		NavigationStack {
			ScrollViewReader { scrollProxy in
				VStack(alignment: .leading) {
					// Horizontal scrollable segment
					ScrollView(.horizontal, showsIndicators: false) {
						HStack(spacing: 10) {
							ForEach(iconGroups) { group in
								Button(action: {
									withAnimation {
										scrollProxy.scrollTo(group.name, anchor: .top)
									}
								}) {
									Text(group.name)
										.padding(.horizontal, 12)
										.padding(.vertical, 8)
										.background(Color.blue.opacity(0.2))
										.cornerRadius(10)
								}
							}
						}
						.padding(.horizontal)
					}
					.padding(.vertical, 10)

					ScrollView(showsIndicators: false) {
						LazyVStack(alignment: .leading, spacing: 20) {
							ForEach(iconGroups) { group in
								VStack(alignment: .leading) {
									Text(group.name)
										.font(.headline)
										.padding(.horizontal)

									LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 20) {
										ForEach(group.symbols, id: \.self) { symbol in
											VStack {
												Image(systemName: symbol)
													.resizable()
													.scaledToFit()
													.frame(width: 40, height: 40)
													.padding(8)
												Text(symbol)
													.font(.caption)
													.multilineTextAlignment(.center)
											}
											.onTapGesture {
												projectIcon = symbol
												dismiss()
											}
										}
									}
									.padding(.horizontal)
								}
								.id(group.name) // Assign ID for scroll anchoring
							}
						}
					}
				}
			}
			.navigationTitle("Project Icon")
			#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
			#endif
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button {
						dismiss()
					} label: {
						Label("Cancel", systemImage: "xmark.circle.fill")
					}
				}
			}
		}
    }
}

#Preview {
	
	@Previewable @State var projectIcon: String = "square.stack.fill"
	
	SymbolGridView(projectIcon: $projectIcon)
}
