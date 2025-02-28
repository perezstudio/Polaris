//
//  RecurrenceManager.swift
//  Polaris
//
//  Created on 2/24/25.
//

import SwiftUI
import SwiftData

class RecurrenceManager {
	static let shared = RecurrenceManager()
	
	// Process all recurring todos that need attention
	func processRecurringTodos(modelContext: ModelContext) {
		let descriptor = FetchDescriptor<Todo>(
			predicate: #Predicate<Todo> { todo in
				todo.isRecurring == true && todo.status == false
			}
		)
		
		// Try to fetch all recurring, incomplete todos
		do {
			let recurringTodos = try modelContext.fetch(descriptor)
			for todo in recurringTodos {
				// Check if this is a recurring todo that needs updating
				checkAndUpdateRecurrence(todo: todo, modelContext: modelContext)
			}
		} catch {
			print("Error fetching recurring todos: \(error.localizedDescription)")
		}
	}
	
	// Check if a todo's recurrence needs to be adjusted
	private func checkAndUpdateRecurrence(todo: Todo, modelContext: ModelContext) {
		// Generate instances for missed dates, if appropriate
		if shouldGenerateMissedOccurrences(todo: todo) {
			generateMissedOccurrences(todo: todo, modelContext: modelContext)
		}
	}
	
	// Determine if we should generate occurrences for dates that have passed
	private func shouldGenerateMissedOccurrences(todo: Todo) -> Bool {
		// Only check todos that have due dates in the past
		guard let dueDate = todo.dueDate else {
			return false
		}
		
		// Get current date for comparison
		let currentDate = Date()
		
		if dueDate >= currentDate {
			return false
		}
		
		// If this is a child recurrence, don't auto-generate (parent handles this)
		if todo.parentTodoID != nil {
			return false
		}
		
		// If it's past the recurrence end date, don't generate
		if let endDate = todo.recurrenceEndDate, endDate < currentDate {
			return false
		}
		
		// If it's reached its recurrence count, don't generate
		if let count = todo.recurrenceCount, count <= 0 {
			return false
		}
		
		return true
	}
	
	// Generate occurrences for dates that have passed
	private func generateMissedOccurrences(todo: Todo, modelContext: ModelContext) {
		guard let dueDate = todo.dueDate else { return }
		
		let currentDate = Date()
		var nextTodo: Todo? = todo
		
		// Keep generating until we reach today or future
		while let currentTodo = nextTodo,
			  let currentDueDate = currentTodo.dueDate,
			  currentDueDate < currentDate {
			
			// Generate next occurrence
			nextTodo = currentTodo.generateNextOccurrence(modelContext: modelContext)
			
			// Update the original todo if this is the first iteration
			if currentTodo.id == todo.id {
				// Mark the original as complete when generating missed occurrences
				currentTodo.status = true
			}
		}
		
		// Save changes
		try? modelContext.save()
	}
	
	// Handle updates to a parent recurring todo (propagate changes to future occurrences)
	func updateFutureOccurrences(parentTodo: Todo, modelContext: ModelContext) {
		// Get the parent ID - no need to unwrap as UUID is non-optional in your model
		let parentId = parentTodo.id
		let currentDate = Date()
		
		// We'll need to fetch todos manually and filter in code
		let descriptor = FetchDescriptor<Todo>()
		
		do {
			let allTodos = try modelContext.fetch(descriptor)
			
			// Filter to find child todos with matching parent ID and future dates
			let childTodos = allTodos.filter { todo in
				if let parentTodoID = todo.parentTodoID,
				   parentTodoID == parentId,
				   let dueDate = todo.dueDate,
				   dueDate > currentDate {
					return true
				}
				return false
			}
			
			for childTodo in childTodos {
				// Update properties that should be synced with parent
				childTodo.title = parentTodo.title
				childTodo.notes = parentTodo.notes
				childTodo.isRecurring = parentTodo.isRecurring
				childTodo.recurrencePattern = parentTodo.recurrencePattern
				childTodo.recurrenceEndDate = parentTodo.recurrenceEndDate
				childTodo.customRecurrenceData = parentTodo.customRecurrenceData
				
				// Preserve the original due date spacing
				if let childDueDate = childTodo.dueDate, let parentDueDate = parentTodo.dueDate {
					// If parent's due date changed, we need to adjust all children proportionally
					if parentTodo.recurrencePatternEnum == .custom {
						// For custom patterns, recalculate based on custom rules
						if let customData = parentTodo.getCustomRecurrence() {
							// Recalculate the due date sequence starting from parent
							var newDueDate = parentDueDate
							var currentTodo = parentTodo
							
							// Find this child's position in the sequence
							var foundChild = false
							while !foundChild {
								if let nextDate = calculateNextDateForTodo(currentTodo) {
									newDueDate = nextDate
									if childTodo.id == currentTodo.id {
										foundChild = true
										childTodo.dueDate = newDueDate
										break
									}
								} else {
									break
								}
								
								// Set up for next iteration
								let tempTodo = Todo(
									title: currentTodo.title,
									dueDate: newDueDate,
									isRecurring: currentTodo.isRecurring,
									recurrencePattern: currentTodo.recurrencePatternEnum
								)
								tempTodo.customRecurrenceData = currentTodo.customRecurrenceData
								currentTodo = tempTodo
							}
						}
					}
				}
				
				// Update project association if needed
				childTodo.project = parentTodo.project
			}
			
			try? modelContext.save()
		} catch {
			print("Error updating future occurrences: \(error.localizedDescription)")
		}
	}
	
	// Helper function to calculate next date based on todo's recurrence settings
	private func calculateNextDateForTodo(_ todo: Todo) -> Date? {
		guard let dueDate = todo.dueDate else { return nil }
		
		if todo.recurrencePatternEnum == .custom, let customData = todo.getCustomRecurrence() {
			// Calculate custom next date
			return calculateCustomNextDate(dueDate: dueDate, customData: customData)
		} else {
			// Use standard pattern
			return todo.recurrencePatternEnum.nextDate(from: dueDate)
		}
	}
	
	// Duplicate of todo's custom calculation to avoid circular dependencies
	private func calculateCustomNextDate(dueDate: Date, customData: CustomRecurrence) -> Date? {
		let calendar = Calendar.current
		
		switch customData.unit {
		case .day:
			return calendar.date(byAdding: .day, value: customData.frequency, to: dueDate)
			
		case .week:
			if let daysOfWeek = customData.daysOfWeek, !daysOfWeek.isEmpty {
				var nextDate = dueDate
				
				repeat {
					nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate)!
					let weekday = calendar.component(.weekday, from: nextDate)
					if daysOfWeek.contains(weekday) {
						return nextDate
					}
				} while calendar.dateComponents([.day], from: dueDate, to: nextDate).day! < 7 * customData.frequency
				
				return calendar.date(byAdding: .weekOfYear, value: customData.frequency, to: dueDate)
			} else {
				return calendar.date(byAdding: .weekOfYear, value: customData.frequency, to: dueDate)
			}
			
		case .month:
			if let dayOfMonth = customData.dayOfMonth {
				var dateComponents = calendar.dateComponents([.year, .month], from: dueDate)
				dateComponents.month! += customData.frequency
				dateComponents.day = min(dayOfMonth, calendar.range(of: .day, in: .month, for: calendar.date(from: dateComponents)!)!.count)
				return calendar.date(from: dateComponents)
			} else {
				return calendar.date(byAdding: .month, value: customData.frequency, to: dueDate)
			}
			
		case .year:
			return calendar.date(byAdding: .year, value: customData.frequency, to: dueDate)
		}
	}
	
	// Function to handle deleting a recurring todo
	func handleRecurringTodoDeletion(todo: Todo, modelContext: ModelContext, deleteFuture: Bool) {
		if deleteFuture {
			// Delete all future occurrences of this todo
			deleteFutureOccurrences(todo: todo, modelContext: modelContext)
		}
		
		// If this is part of a recurring series but not the parent, update parent's recurrence settings
		if let parentID = todo.parentTodoID {
			// We'll fetch all todos and filter in code
			let descriptor = FetchDescriptor<Todo>()
			
			do {
				let allTodos = try modelContext.fetch(descriptor)
				if let parent = allTodos.first(where: { $0.id == parentID }) {
					// Update parent's recurrence count if needed
					if let count = parent.recurrenceCount {
						parent.recurrenceCount = max(0, count - 1)
					}
				}
			} catch {
				print("Error updating parent todo: \(error.localizedDescription)")
			}
		}
		
		// Delete this todo
		modelContext.delete(todo)
		try? modelContext.save()
	}
	
	// Delete all future occurrences of a recurring todo
	private func deleteFutureOccurrences(todo: Todo, modelContext: ModelContext) {
		// Get the parent ID (could be this todo's ID or its parent)
		// Since parentTodoID is optional but id is not, use nil coalescing
		let parentID = todo.parentTodoID ?? todo.id
		let currentDate = Date()
		
		// Since we can't use complex predicates, we'll fetch all and filter in code
		let descriptor = FetchDescriptor<Todo>()
		
		do {
			let allTodos = try modelContext.fetch(descriptor)
			let dueDateToMatch = todo.dueDate ?? currentDate
			
			// Filter todos that match our criteria
			let todosToDelete = allTodos.filter { relatedTodo in
				if let relatedDueDate = relatedTodo.dueDate {
					if (relatedTodo.parentTodoID == parentID || relatedTodo.id == parentID) &&
					   relatedDueDate >= dueDateToMatch &&
					   relatedTodo.id != todo.id {
						return true
					}
				}
				return false
			}
			
			// Delete filtered todos
			for relatedTodo in todosToDelete {
				modelContext.delete(relatedTodo)
			}
			
			try? modelContext.save()
		} catch {
			print("Error deleting future occurrences: \(error.localizedDescription)")
		}
	}
}
