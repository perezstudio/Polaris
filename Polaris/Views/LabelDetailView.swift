//
//  LabelDetailView.swift
//  Polaris
//
//  Created by Kevin Perez on 8/3/25.
//

import SwiftUI

struct LabelDetailView: View {
	let label: TaskLabelModel
	
	var body: some View {
		Text("Label: \(label.name)")
			.navigationTitle(label.name)
	}
}

#Preview {
	LabelDetailView(label: TaskLabelModel(name: "Sample Label", color: .blue))
}