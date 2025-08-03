//
//  NoteEditorView.swift
//  Polaris
//
//  Created by Kevin Perez on 5/2/25.
//

import SwiftUI

struct NoteEditorView: View {
	@Binding var text: String

	var body: some View {
		VStack(spacing: 0) {
			TextEditor(text: $text)
		}
		.navigationTitle("Edit Note")
	}
}
