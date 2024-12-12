//
//  TaskListContent.swift
//  Polaris
//
//  Created by Kevin Perez on 12/12/24.
//


// Add imports
import SwiftUI

struct TaskListContent: View {
    let todos: [Todo]
    let groupedTasks: [(key: String, tasks: [Todo])]
    @Binding var selectedTask: Todo?
    @Binding var openTaskDetailsInspector: Bool
    @Binding var openCreateTaskSheet: Bool
    
    var body: some View {
        if todos.isEmpty {
            ContentUnavailableView {
                Label("No Tasks", systemImage: "checkmark.square")
            } description: {
                Text("Create a new task to see it listed in your project.")
            } actions: {
                Button {
                    openCreateTaskSheet.toggle()
                } label: {
                    Label("Create New Task", systemImage: "plus.square")
                }
            }
        } else {
            ForEach(groupedTasks, id: \.key) { group in
                Section(group.key) {
                    ForEach(group.tasks) { todo in
                        Button {
                            if selectedTask == todo {
                                openTaskDetailsInspector.toggle()
                            } else {
                                selectedTask = todo
                                openTaskDetailsInspector = true
                            }
                        } label: {
                            TaskRowView(todo: todo)
                        }
                    }
                }
            }
        }
    }
}

// End of file
