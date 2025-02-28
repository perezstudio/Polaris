//
//  TodoInspector.swift
//  Polaris
//
//  Created by Kevin Perez on 2/27/25.
//

import SwiftUI
import SwiftData

// Custom environment keys for Inspector properties
private struct TodoInspectorKey: EnvironmentKey {
	static let defaultValue = Inspector()
}

// Extension to make the inspector easily accessible via environment
extension EnvironmentValues {
	var todoInspector: Inspector {
		get { self[TodoInspectorKey.self] }
		set { self[TodoInspectorKey.self] = newValue }
	}
}

// Extension to provide convenient binding-like access to show state
extension EnvironmentValues {
	var showTodoInspector: Binding<Bool> {
		Binding(
			get: { self.todoInspector.showTodoInspector },
			set: { self.todoInspector.showTodoInspector = $0 }
		)
	}
}

// Extension to provide convenient optional binding for todo
extension EnvironmentValues {
	var inspectedTodo: Binding<Todo?> {
		Binding(
			get: { self.todoInspector.todo },
			set: { self.todoInspector.todo = $0 }
		)
	}
}

// Extension to make it easy to inject the inspector
extension View {
	func todoInspector(_ inspector: Inspector) -> some View {
		environment(\.todoInspector, inspector)
	}
}

// Your existing Inspector class remains the same
@Observable class Inspector {
	var todo: Todo? = nil
	var showTodoInspector: Bool = false
}
