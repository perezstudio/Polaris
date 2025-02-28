import SwiftUI
import SwiftData

@Model
class Todo {
	var id: UUID = UUID()
	var title: String = ""
	var notes: String = ""
	var status: Bool = false
	var dueDate: Date?
	var deadLineDate: Date?
	var inbox: Bool = false
	
	// Recurrence properties
	var isRecurring: Bool = false
	var recurrencePattern: String = RecurrencePattern.none.rawValue
	var recurrenceEndDate: Date?
	var recurrenceCount: Int? // Limit to specific number of occurrences
	var customRecurrenceData: Data? // To store CustomRecurrence as JSON
	var parentTodoID: UUID? // For linking generated recurrences to their parent
	
	@Relationship(deleteRule: .nullify, inverse: \Project.todos) var project: [Project]? = []
	var created: Date = Date()
	
	init(id: UUID = UUID(), title: String = "", notes: String = "", status: Bool = false,
		 dueDate: Date? = nil, deadLineDate: Date? = nil, inbox: Bool = false,
		 project: [Project]? = [], isRecurring: Bool = false,
		 recurrencePattern: RecurrencePattern = .none, recurrenceEndDate: Date? = nil,
		 recurrenceCount: Int? = nil, parentTodoID: UUID? = nil) {
		
		self.id = id
		self.title = title
		self.notes = notes
		self.status = status
		self.dueDate = dueDate
		self.deadLineDate = deadLineDate
		self.inbox = inbox
		self.project = project
		
		// Initialize recurrence properties
		self.isRecurring = isRecurring
		self.recurrencePattern = recurrencePattern.rawValue
		self.recurrenceEndDate = recurrenceEndDate
		self.recurrenceCount = recurrenceCount
		self.parentTodoID = parentTodoID
	}
	
	@Transient var dueDateMonth: Int {
		let calendar = Calendar.current
		if dueDate != nil {
			return calendar.component(.month, from: dueDate ?? Date.now)
		} else {
			return 0
		}
	}
	
	@Transient var dueDateDay: Int {
		let calendar = Calendar.current
		if dueDate != nil {
			return calendar.component(.day, from: dueDate ?? Date.now)
		} else {
			return 0
		}
	}
	
	@Transient var dueDateYear: Int {
		let calendar = Calendar.current
		if dueDate != nil {
			return calendar.component(.year, from: dueDate ?? Date.now)
		} else {
			return 0
		}
	}
	
	// Helper computed property to access RecurrencePattern enum
	@Transient var recurrencePatternEnum: RecurrencePattern {
		get {
			return RecurrencePattern(rawValue: recurrencePattern) ?? .none
		}
		set {
			recurrencePattern = newValue.rawValue
		}
	}
	
	// Helper method to store custom recurrence data
	func setCustomRecurrence(_ customRecurrence: CustomRecurrence) {
		do {
			let encoder = JSONEncoder()
			self.customRecurrenceData = try encoder.encode(customRecurrence)
		} catch {
			print("Error encoding custom recurrence: \(error)")
		}
	}
	
	// Helper method to retrieve custom recurrence data
	func getCustomRecurrence() -> CustomRecurrence? {
		guard let data = customRecurrenceData else { return nil }
		
		do {
			let decoder = JSONDecoder()
			return try decoder.decode(CustomRecurrence.self, from: data)
		} catch {
			print("Error decoding custom recurrence: \(error)")
			return nil
		}
	}
	
	// Generate the next occurrence of this todo based on recurrence pattern
	func generateNextOccurrence(modelContext: ModelContext) -> Todo? {
		guard isRecurring, let dueDate = dueDate else { return nil }
		
		// Check if we've reached recurrence limits
		if let recurrenceCount = recurrenceCount, recurrenceCount <= 0 {
			return nil
		}
		
		if let endDate = recurrenceEndDate, endDate < Date() {
			return nil
		}
		
		var nextDueDate: Date?
		
		if recurrencePatternEnum == .custom, let customData = getCustomRecurrence() {
			// Handle custom recurrence calculation
			nextDueDate = calculateCustomNextDate(dueDate: dueDate, customData: customData)
		} else {
			// Use standard recurrence patterns
			nextDueDate = recurrencePatternEnum.nextDate(from: dueDate)
		}
		
		guard let newDueDate = nextDueDate else { return nil }
		
		// Create new todo instance
		let newTodo = Todo(
			title: title,
			notes: notes,
			status: false,
			dueDate: newDueDate,
			deadLineDate: deadLineDate,
			inbox: inbox,
			project: project,
			isRecurring: isRecurring,
			recurrencePattern: recurrencePatternEnum,
			recurrenceEndDate: recurrenceEndDate,
			recurrenceCount: recurrenceCount != nil ? recurrenceCount! - 1 : nil,
			parentTodoID: id // Link back to parent
		)
		
		if let customData = customRecurrenceData {
			newTodo.customRecurrenceData = customData
		}
		
		// Insert new todo into data context
		modelContext.insert(newTodo)
		
		return newTodo
	}
	
	private func calculateCustomNextDate(dueDate: Date, customData: CustomRecurrence) -> Date? {
		let calendar = Calendar.current
		
		switch customData.unit {
		case .day:
			return calendar.date(byAdding: .day, value: customData.frequency, to: dueDate)
			
		case .week:
			// If specific days of week are specified, find the next occurrence
			if let daysOfWeek = customData.daysOfWeek, !daysOfWeek.isEmpty {
				// Complex logic for weekly recurrence on specific days
				// This is a simplified version
				var nextDate = dueDate
				
				repeat {
					nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate)!
					let weekday = calendar.component(.weekday, from: nextDate)
					if daysOfWeek.contains(weekday) {
						return nextDate
					}
				} while calendar.dateComponents([.day], from: dueDate, to: nextDate).day! < 7 * customData.frequency
				
				// If we didn't find a day in the next frequency period, just add weeks
				return calendar.date(byAdding: .weekOfYear, value: customData.frequency, to: dueDate)
			} else {
				// Simple weekly recurrence
				return calendar.date(byAdding: .weekOfYear, value: customData.frequency, to: dueDate)
			}
			
		case .month:
			// Complex logic for "nth day of month" or "nth weekday of month"
			if let dayOfMonth = customData.dayOfMonth {
				var dateComponents = calendar.dateComponents([.year, .month], from: dueDate)
				dateComponents.month! += customData.frequency
				dateComponents.day = min(dayOfMonth, calendar.range(of: .day, in: .month, for: calendar.date(from: dateComponents)!)!.count)
				return calendar.date(from: dateComponents)
			} else {
				// Default to simple month addition
				return calendar.date(byAdding: .month, value: customData.frequency, to: dueDate)
			}
			
		case .year:
			return calendar.date(byAdding: .year, value: customData.frequency, to: dueDate)
		}
	}
}
