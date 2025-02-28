//
//  SearchView.swift
//  Polaris
//
//  Created by Kevin Perez on 12/26/24.
//

import SwiftUI
import SwiftData

struct SearchView: View {
	@Environment(\.modelContext) private var modelContext
	@Query(sort: \Todo.created, order: .forward) var allTodos: [Todo]
	@Query(sort: \SearchItem.created, order: .reverse) var searchItems: [SearchItem]

	@State private var searchText = ""
	@State private var activeSearchText = ""  // Add this to track the actual search term
	@State private var activeTodo: Todo? = nil
	@State private var newlyCreatedTodo: Todo? = nil

	var filteredTodos: [Todo] {
		guard !activeSearchText.isEmpty else { return [] }
		return allTodos.filter { todo in
			todo.title.localizedCaseInsensitiveContains(activeSearchText) ||
			todo.notes.localizedCaseInsensitiveContains(activeSearchText)
		}
	}

	var showingSearchResults: Bool {
		!activeSearchText.isEmpty
	}

	private func saveSearchItem() {
		guard !activeSearchText.isEmpty else { return }
		let searchItem = SearchItem(text: activeSearchText)
		modelContext.insert(searchItem)

		do {
			try modelContext.save()
		} catch {
			print("Error saving search item: \(error.localizedDescription)")
		}
	}
	
	private func clearSearch() {
		searchText = ""
		activeSearchText = ""
	}
	
	private func deleteSearchItem(_ item: SearchItem) {
		modelContext.delete(item)
		try? modelContext.save()
	}

	var body: some View {
		NavigationStack {
			ScrollView(showsIndicators: false) {
				// Rest of your view code remains the same
				VStack(spacing: 16) {
					if showingSearchResults {
						ForEach(filteredTodos) { todo in
							TodoCard(
								todo: todo,
								showDetails: .constant(activeTodo == todo),
								isNewTodo: todo == newlyCreatedTodo
							)
							.onTapGesture {
								withAnimation {
									if activeTodo == todo {
										activeTodo = nil
									} else {
										activeTodo = todo
									}
								}
							}
						}

						if filteredTodos.isEmpty {
							ContentUnavailableView.search
						}
					} else {
						if !searchItems.isEmpty {
							VStack {
								VStack(alignment: .leading, spacing: 12) {
									ForEach(searchItems) { item in
										HStack {
											MenuItem(icon: "clock", title: item.text, color: Color.blue)
										}
										.contentShape(Rectangle())
										.onTapGesture {
											searchText = item.text
											activeSearchText = item.text
										}
										.swipeActions(edge: .trailing, allowsFullSwipe: true) {
											Button(role: .destructive) {
												withAnimation {
													deleteSearchItem(item)
												}
											} label: {
												Label("Delete", systemImage: "trash")
											}
										}
									}
								}
								#if os(iOS)
								.background(Color(.secondarySystemGroupedBackground))
								#endif
								.cornerRadius(12)
							}
							.padding(.horizontal, 16)
							.frame(maxWidth: .infinity, alignment: .leading)
						} else {
							ContentUnavailableView {
								Label {
									Text("No Recent Searches")
								} icon: {
									Image(systemName: "magnifyingglass")
										.foregroundStyle(Color.blue)
								}
							}
						}
					}
				}
			}
			.onTapGesture {
				withAnimation {
					activeTodo = nil
				}
			}
			.onChange(of: activeTodo) { _, newValue in
				if newValue == nil {
					newlyCreatedTodo = nil
				}
			}
			.navigationTitle("Search")
			.searchable(
				text: $searchText,
				prompt: "Search todos...",
				suggestions: {
					ForEach(searchItems.prefix(5)) { item in
						Text(item.text)
							.searchCompletion(item.text)
					}
				}
			)
			.onChange(of: searchText) { _, newValue in
				if newValue.isEmpty {
					activeSearchText = "" // Clear active search when text is cleared
				}
			}
			.onSubmit(of: .search) {
				activeSearchText = searchText
				saveSearchItem()
			}
			#if os(iOS)
			.navigationBarTitleDisplayMode(.large)
			.background(Color(.systemGroupedBackground))
			#endif
		}
	}
}

#Preview {
	SearchView()
}
