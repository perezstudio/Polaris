//
//  InboxView.swift
//  Polaris
//
//  Created by Kevin Perez on 4/27/25.
//

import SwiftUI
import SwiftData

struct InboxView: View {
	
	@Environment(GlobalStore.self) var store
	@Query(filter: #Predicate<Todo> { $0.isInbox == true && $0.isCompleted == false })
	private var todos: [Todo] = []
	@State var showCreateTodoSheet: Bool = false
	
	var body: some View {
		NavigationStack {
			List {
				if !todos.isEmpty {
					SwiftUI.Section {
						ForEach(todos) { todo in
							TodoListView(todo: todo)
								.onTapGesture {
									store.selectedTodo = todo
									store.showInspector = true
								}
						}
					}
				} else {
					ContentUnavailableView {
						Label {
							Text("No Todos Left")
						} icon: {
							Image(systemName: "tray.fill")
								.foregroundStyle(Color.blue)
						}
					} description: {
						Text("Great Job! You're on a roll!")
					} actions: {
						Button {
							showCreateTodoSheet.toggle()
						} label: {
							Label("Create Todo", systemImage: "plus")
						}
					}
				}
			}
			.navigationTitle("Inbox")
			#if os(iOS)
			.navigationBarTitleDisplayMode(.large)
			.toolbar {
				ToolbarItemGroup(placement: .bottomBar) {
					Spacer()
					Button {
						print("Create Todo")
					} label: {
						Label("New Todo", systemImage: "plus.square.fill")
					}
				}
			}
			#elseif os(macOS)
			.toolbar {
				ToolbarItemGroup(placement: .navigation) {
					Spacer()
					Button {
						print("Create Todo")
					} label: {
						Label("New Todo", systemImage: "plus.square.fill")
					}
				}
			}
			#endif
			.sheet(isPresented: $showCreateTodoSheet) {
				CreateTodoView()
			}
		}
	}
}

#Preview {
	InboxView()
}
