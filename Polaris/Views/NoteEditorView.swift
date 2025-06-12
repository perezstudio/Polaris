//
//  NoteEditorView.swift
//  Polaris
//
//  Created by Kevin Perez on 5/2/25.
//

import SwiftUI

struct NoteEditorView: View {
	@Binding var attributedText: NSAttributedString
	@State private var uiTextView: UITextView? = nil

	var body: some View {
		VStack(spacing: 0) {
			RichTextEditor(text: $attributedText, uiTextView: $uiTextView)
				.frame(minHeight: 200)
				.cornerRadius(8)
				.padding()

			Divider()

			HStack {
				Button { toggleStyle(.traitBold) } label: { Image(systemName: "bold") }
				Spacer()
				Button { toggleStyle(.traitItalic) } label: { Image(systemName: "italic") }
				Spacer()
				Button { toggleUnderline() } label: { Image(systemName: "underline") }
			}
			.padding()
			.background(Color(UIColor.tertiarySystemBackground))
		}
		.navigationTitle("Edit Note")
	}

	private func toggleStyle(_ trait: UIFontDescriptor.SymbolicTraits) {
		guard let textView = uiTextView else { return }
		let range = textView.selectedRange
		guard range.length > 0 else { return }

		let attributed = NSMutableAttributedString(attributedString: textView.attributedText)
		attributed.enumerateAttribute(.font, in: range) { value, range, _ in
			if let font = value as? UIFont {
				var traits = font.fontDescriptor.symbolicTraits
				traits.formSymmetricDifference(trait)
				if let newDesc = font.fontDescriptor.withSymbolicTraits(traits) {
					let newFont = UIFont(descriptor: newDesc, size: font.pointSize)
					attributed.addAttribute(.font, value: newFont, range: range)
				}
			}
		}
		textView.attributedText = attributed
		attributedText = attributed
	}

	private func toggleUnderline() {
		guard let textView = uiTextView else { return }
		let range = textView.selectedRange
		guard range.length > 0 else { return }

		let attributed = NSMutableAttributedString(attributedString: textView.attributedText)
		attributed.enumerateAttribute(.underlineStyle, in: range) { value, range, _ in
			let current = (value as? Int) ?? 0
			let new = current == 0 ? NSUnderlineStyle.single.rawValue : 0
			attributed.addAttribute(.underlineStyle, value: new, range: range)
		}
		textView.attributedText = attributed
		attributedText = attributed
	}
}
