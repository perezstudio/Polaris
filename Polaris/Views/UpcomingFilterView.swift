import SwiftUI
import SwiftData

private extension Calendar {
	func generateDates(inside interval: DateInterval, matching components: DateComponents) -> [Date] {
		var dates: [Date] = []
		dates.append(interval.start)
		enumerateDates(
			startingAfter: interval.start,
			matching: components,
			matchingPolicy: .nextTime
		) { date, _, stop in
			if let date = date {
				if date < interval.end {
					dates.append(date)
				} else {
					stop = true
				}
			}
		}
		return dates
	}
}

struct UpcomingFilterView: View {
	@Query(filter: #Predicate<Todo> { todo in
		todo.status == false && todo.dueDate != nil
	}, sort: \Todo.dueDate) private var todos: [Todo]
	
	@State private var selectedDate: Date = Calendar.current.startOfDay(for: .now)
	@State private var scrollTarget: String?
	@State private var listScrollTarget: Date?
	@State private var visibleHeaderDate: Date? = nil
	@State private var headerFrames: [DateFrame] = []
	@State private var openCreateTaskSheet: Bool = false
	@State private var openTaskDetailsInspector: Bool = false
	@State private var selectedTask: Todo? = nil
	
	@State private var scrollViewWidth: CGFloat = 0
	@State private var additionalWeeks: Int = 0
	@State private var isLoadingMoreWeeks: Bool = false
	
	private var visibleDates: [Date] {
		let calendar = Calendar.current
		let today = Date.now
		let weekday = calendar.component(.weekday, from: today)
		let daysToSubtract = weekday - calendar.firstWeekday
		let startOfCurrentWeek = calendar.date(byAdding: .day, value: -daysToSubtract, to: today)!
		
		let startDate = calendar.date(byAdding: .day, value: -21, to: startOfCurrentWeek)!
		let endDate = calendar.date(byAdding: .day, value: 42 + (additionalWeeks * 7), to: startOfCurrentWeek)!
		
		return calendar.generateDates(
			inside: DateInterval(start: startDate, end: endDate),
			matching: DateComponents(hour: 0, minute: 0, second: 0)
		)
	}
	
	private var weekGroups: [[Date]] {
		let calendar = Calendar.current
		let grouped = Dictionary(grouping: visibleDates) { date in
			calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
		}
		return grouped.values.sorted { dates1, dates2 in
			guard let first1 = dates1.first, let first2 = dates2.first else { return false }
			return first1 < first2
		}
	}
	
	private var groupedTasks: [(date: Date, tasks: [Todo])] {
		visibleDates.map { date in
			let dayTasks = todos.filter { todo in
				guard let dueDate = todo.dueDate else { return false }
				return Calendar.current.isDate(dueDate, inSameDayAs: date)
			}
			return (date: date, tasks: dayTasks)
		}
	}
	
	private var currentWeekIndex: Int {
		weekGroups.firstIndex(where: { week in
			week.contains(where: { Calendar.current.isDate($0, inSameDayAs: selectedDate) })
		}) ?? 0
	}
	
	private var isSelectedDateToday: Bool {
		Calendar.current.isDate(selectedDate, inSameDayAs: .now)
	}
	
	private var currentMonthText: String {
		let formatter = DateFormatter()
		formatter.dateFormat = "MMMM yyyy"
		return formatter.string(from: selectedDate)
	}
	
	private func scrollToDate(_ date: Date) {
		withAnimation {
			selectedDate = date
		}
		
		DispatchQueue.main.async {
			scrollTarget = "week_\(currentWeekIndex)"
		}
		
		DispatchQueue.main.async {
			listScrollTarget = date
		}
	}
	
	private func loadMoreWeeksIfNeeded(currentWeekIndex: Int) {
		let threshold = weekGroups.count - 2
		if currentWeekIndex >= threshold && !isLoadingMoreWeeks {
			isLoadingMoreWeeks = true
			withAnimation {
				additionalWeeks += 2
			}
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				isLoadingMoreWeeks = false
			}
		}
	}
	
	var body: some View {
		VStack(spacing: 0) {
			ScrollViewReader { proxy in
				GeometryReader { geometry in
					ScrollView(.horizontal, showsIndicators: false) {
						LazyHStack(spacing: 0) {
							ForEach(Array(weekGroups.enumerated()), id: \.0) { weekIndex, dates in
								CalendarWeekView(
									dates: dates,
									selectedDate: selectedDate,
									onDateSelected: { date in
										scrollToDate(date)
									}
								)
								.frame(width: geometry.size.width)
								.id("week_\(weekIndex)")
							}
						}
					}
					.scrollTargetLayout()
					.scrollTargetBehavior(.viewAligned)
					.scrollPosition(id: $scrollTarget)
				}
				.frame(height: 80)
				.background(Color.secondary.opacity(0.1))
				.onChange(of: selectedDate, initial: false) { oldValue, newValue in
					withAnimation {
						proxy.scrollTo("week_\(currentWeekIndex)", anchor: .leading)
						loadMoreWeeksIfNeeded(currentWeekIndex: currentWeekIndex)
					}
				}
			}
			
			ScrollViewReader { proxy in
				ScrollView {
					LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
						TaskListView(
							tasks: groupedTasks,
							selectedTask: $selectedTask,
							openTaskDetailsInspector: $openTaskDetailsInspector,
							scrollNamespace: "scroll",
							onHeaderAppear: { date in
								selectedDate = date
							}
						)
						.onPreferenceChange(ScrollPositionPreferenceKey.self) { frames in
							if let topMostHeader = frames
								.filter({ $0.frame.minY <= 0 })
								.max(by: { $0.frame.minY < $1.frame.minY }),
								!Calendar.current.isDate(topMostHeader.date, inSameDayAs: selectedDate) {
								withAnimation {
									selectedDate = topMostHeader.date
								}
							}
						}
					}
					.scrollTargetLayout()
				}
				.scrollTargetBehavior(.viewAligned)
				.coordinateSpace(name: "scroll")
				.onChange(of: listScrollTarget, initial: false) { oldValue, newValue in
					if let target = newValue {
						withAnimation {
							proxy.scrollTo("header_\(target)", anchor: .top)
						}
					}
				}
			}
		}
		.navigationTitle(currentMonthText)
		#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				if !isSelectedDateToday {
					Button {
						let today = Calendar.current.startOfDay(for: .now)
						scrollToDate(today)
					} label: {
						Text("Today")
					}
				}
			}
			ToolbarItemGroup(placement: .bottomBar) {
				Spacer()
				Button {
					openCreateTaskSheet.toggle()
				} label: {
					Label("Create Task", systemImage: "plus.square")
				}
			}
		}
		#endif
		.sheet(isPresented: $openCreateTaskSheet) {
			CreateTodoView()
		}
		.inspector(isPresented: $openTaskDetailsInspector) {
			if let task = selectedTask {
				TaskDetailsView(todo: task, sheetState: $openTaskDetailsInspector)
			} else {
				ContentUnavailableView("No Task Selected", systemImage: "checklist")
			}
		}
		.onAppear {
			let today = Calendar.current.startOfDay(for: .now)
			selectedDate = today
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				scrollToDate(today)
			}
		}
	}
}
