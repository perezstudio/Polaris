//
//  TodoInspectorView.swift
//  Polaris
//
//  Created by Kevin Perez on 5/26/25.
//

import SwiftUI

struct TodoInspectorView: View {
	
	@Environment(GlobalStore.self) private var store
	@State private var editingDescription: NSAttributedString = NSAttributedString(string: "")
	
	var body: some View {
		if let todo = store.selectedTodo {
			List {
				SwiftUI.Section(header: Text("Todo")) {
					HStack(spacing: 12) {
						Image(systemName: "checkmark")
							.fontWeight(.bold)
							.foregroundStyle(todo.isCompleted ? Color.white : Color.clear)
							.frame(width: 30, height: 30, alignment: .center)
							.background(todo.isCompleted ? Color.blue : Color.clear)  // Optional: add a background color
							.cornerRadius(8)
							.overlay(
								RoundedRectangle(cornerRadius: 8)
									.stroke(todo.isCompleted ? Color.blue : Color.gray.opacity(0.60), lineWidth: 1)
							)
							.onTapGesture {
								todo.isCompleted.toggle()
							}
						Text(todo.title)
					}
				}
				SwiftUI.Section(header: Text("Todo Description")) {
					NavigationLink(
						destination: NoteEditorView(attributedText: $editingDescription),
						label: {
							if let description = todo.descriptionText, !description.isEmpty,
							   let formatted = try? AttributedString(markdown: description) {
								Text(formatted)
							} else {
								Text("Tap to Add Notes")
									.foregroundColor(.secondary)
							}
						}
					)
					.onAppear {
						editingDescription = NSAttributedString(string: todo.descriptionText ?? "")
					}
				}
			}
			.navigationTitle("Create Todo")
			#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						store.showInspector = false
						store.selectedTodo = nil
					} label: {
						Label("Close", systemImage: "xmark.circle.fill")
					}
				}
			}
			#elseif os(macOS)
			.toolbar {
				ToolbarItem(placement: .navigation) {
					Button {
						dismiss()
					} label: {
						Label("Close", systemImage: "xmark.circle.fill")
					}
				}
			}
			#endif
		} else {
			ContentUnavailableView("No Todo Selected", systemImage: "checkmark.circle")
		}
	}
}
