//
//  TodoDetailsView.swift
//  Polaris
//
//  Created by Kevin Perez on 2/27/25.
//

import SwiftUI

struct TodoDetailsView: View {
	
	@Bindable var todo: Todo
	
    var body: some View {
		NavigationStack {
			VStack(alignment: .leading) {
				Text(todo.title)
					.font(.title)
					.fontWeight(.bold)
				Spacer()
			}
			.frame(maxHeight: .infinity, alignment: .leading)
			.padding(16)
			.navigationTitle(todo.project?.first?.title ?? "No Project")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button {
						
					} label: {
						Label("Close Inspector", systemImage: "xmark.circle.fill")
							.labelStyle(.iconOnly)
					}
				}
			}
		}
    }
}

//#Preview {
//    TodoDetailsView()
//}
