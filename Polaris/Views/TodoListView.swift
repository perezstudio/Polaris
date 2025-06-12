//
//  TodoListView.swift
//  Polaris
//
//  Created by Kevin Perez on 4/28/25.
//

import SwiftUI
import SwiftData

struct TodoListView: View {
	
	@Bindable var todo: Todo
	
	var body: some View {
		HStack(spacing: 12) {
			Image(systemName: "checkmark")
				.fontWeight(.bold)
				.foregroundStyle(todo.isCompleted ? Color.white : Color.clear)
				.frame(width: 30, height: 30)
				.background(todo.isCompleted ? Color.blue : Color.clear)
				.cornerRadius(8)
				.overlay(
					RoundedRectangle(cornerRadius: 8)
						.stroke(todo.isCompleted ? Color.blue : Color.gray.opacity(0.60), lineWidth: 1)
				)
				.onTapGesture {
					todo.isCompleted.toggle()
				}
			
			Text(todo.title)
			
			Spacer() // ✅ fill row width
		}
		.padding(.vertical, 4)
		.frame(maxWidth: .infinity, alignment: .leading)
		.contentShape(Rectangle())
	}
}

#Preview {
	
	let newTodo = Todo(title: "Test Todo", isCompleted: false)
	
	TodoListView(todo: newTodo)
}
