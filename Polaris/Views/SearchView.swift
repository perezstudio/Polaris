//
//  SearchView.swift
//  Polaris
//
//  Created by Kevin Perez on 12/26/24.
//

import SwiftUI
import SwiftData

struct SearchView: View {
	// MARK: - Properties
	@Environment(\.modelContext) private var modelContext
	@Query(sort: \Todo.created, order: .forward) var allTodos: [Todo]
	@Query(sort: \SearchItem.created, order: .reverse) var searchItems: [SearchItem]
	
	@State private var searchText = ""
	@State private var activeTodo: Todo? = nil
	@State private var newlyCreatedTodo: Todo? = nil
	
	// MARK: - Computed Properties
	var filteredTodos: [Todo] {
		guard !searchText.isEmpty else { return [] }
		return allTodos.filter { todo in
			todo.title.localizedCaseInsensitiveContains(searchText) ||
			todo.notes.localizedCaseInsensitiveContains(searchText)
		}
	}
	
	var showingSearchResults: Bool {
		!searchText.isEmpty
	}
	
	// MARK: - Body
	var body: some View {
		NavigationStack {
			ZStack {
				// Content
				if showingSearchResults {
					searchResultsView
				} else {
					recentSearchesView
				}
				
				// Clear background to handle taps
				Color.clear
					.contentShape(Rectangle())
					.onTapGesture {
						withAnimation {
							activeTodo = nil
						}
					}
			}
			.searchable(text: $searchText, prompt: "Search todos...")
			.onChange(of: searchText) { _, newValue in
				if newValue.isEmpty {
					withAnimation {
						activeTodo = nil
					}
				}
			}
			.onChange(of: activeTodo) { _, newValue in
				if newValue == nil {
					newlyCreatedTodo = nil
				}
			}
			.navigationTitle("Search")
			.navigationBarTitleDisplayMode(.large)
		}
	}
	
	// MARK: - View Components
	private var searchResultsView: some View {
		ScrollView(showsIndicators: false) {
			VStack(alignment: .leading, spacing: 16) {
				// Recent searches section
				if !searchItems.isEmpty {
					VStack {
						ForEach(searchItems) { item in
							Button(action: {
								searchText = item.text
							}) {
								HStack {
									Image(systemName: "clock.arrow.circlepath")
									Text(item.text)
									Spacer()
								}
								.foregroundColor(.primary)
								.padding(.vertical, 4)
							}
						}
					}
				}
				
				// Search results section
				if filteredTodos.isEmpty {
					ContentUnavailableView.search(text: searchText)
				} else {
					ForEach(filteredTodos) { todo in
						TodoCard(
							todo: todo,
							showDetails: .constant(activeTodo == todo),
							isNewTodo: todo == newlyCreatedTodo
						)
						.onTapGesture {
							toggleActive(todo)
						}
					}
					.onChange(of: activeTodo) { oldValue, newValue in
						// Save search when a todo is selected
						if newValue != nil && oldValue == nil {
							saveSearch()
						}
					}
				}
			}
			.padding()
		}
	}
	
	private var recentSearchesView: some View {
		List {
			if searchItems.isEmpty {
				ContentUnavailableView {
					Label {
						Text("No Recent Searches")
					} icon: {
						Image(systemName: "magnifyingglass")
							.foregroundStyle(Color.gray)
					}
				} description: {
					Text("Your recent searches will appear here")
				}
			} else {
				SwiftUI.Section {
					ForEach(searchItems) { item in
						Button(action: {
							searchText = item.text
						}) {
							HStack {
								Image(systemName: "clock.arrow.circlepath")
								Text(item.text)
								Spacer()
							}
						}
						.foregroundColor(.primary)
					}
				} header: {
					Text("Recent Searches")
				}
			}
		}
	}
	
	// MARK: - Helper Functions
	private func toggleActive(_ todo: Todo) {
		withAnimation {
			if activeTodo == todo {
				activeTodo = nil
			} else {
				activeTodo = todo
			}
		}
	}
	
	private func saveSearch() {
		guard !searchText.isEmpty else { return }
		// Check if search already exists and avoid duplicates
		if !searchItems.contains(where: { $0.text == searchText }) {
			withAnimation {
				let searchItem = SearchItem(text: searchText)
				modelContext.insert(searchItem)
				try? modelContext.save() // Save immediately
				
				// Handle cleanup in a separate operation after successful save
				if searchItems.count >= 10,
				   let oldestSearch = searchItems.last {
					modelContext.delete(oldestSearch)
					try? modelContext.save()
				}
			}
		}
	}
}

#Preview {
	SearchView()
}
