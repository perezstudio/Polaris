//
//  RichTextEditor.swift
//  Polaris
//
//  Created by Kevin Perez on 5/26/25.
//


import SwiftUI
import UIKit

struct RichTextEditor: UIViewRepresentable {
	@Binding var text: NSAttributedString
	@Binding var uiTextView: UITextView?

	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	func makeUIView(context: Context) -> UITextView {
		let textView = UITextView()
		textView.delegate = context.coordinator
		textView.isEditable = true
		textView.isScrollEnabled = true
		textView.font = UIFont.systemFont(ofSize: 16)
		textView.backgroundColor = UIColor.secondarySystemBackground
		textView.attributedText = text
		DispatchQueue.main.async {
			uiTextView = textView
		}
		return textView
	}

	func updateUIView(_ uiView: UITextView, context: Context) {
		if uiView.attributedText != text {
			uiView.attributedText = text
		}
	}

	class Coordinator: NSObject, UITextViewDelegate {
		var parent: RichTextEditor

		init(_ parent: RichTextEditor) {
			self.parent = parent
		}

		func textViewDidChange(_ textView: UITextView) {
			parent.text = textView.attributedText
		}
	}
}
