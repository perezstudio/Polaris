//
//  ViewModifier.swift
//  Polaris
//
//  Created by Kevin Perez on 8/24/25.
//

import SwiftUI

struct EnableSwipeBack: ViewModifier {
	func body(content: Content) -> some View {
		content
			.background(EnableSwipeBackHelper())
	}
}

struct EnableSwipeBackHelper: UIViewControllerRepresentable {
	func makeUIViewController(context: Context) -> UIViewController {
		let controller = UIViewController()
		controller.view.backgroundColor = .clear
		DispatchQueue.main.async {
			controller.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
			controller.navigationController?.interactivePopGestureRecognizer?.delegate = nil
		}
		return controller
	}
	func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
}

extension View {
	func enableSwipeBack() -> some View {
		self.modifier(EnableSwipeBack())
	}
}
