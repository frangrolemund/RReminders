//
//  ReminderModel.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/11/25.
//

import Foundation
import SwiftData

// - the reminder store saves all reminders in their respective lists along with app configuration
@Model
final class ReminderModel {
	var summaryCategories: [SummaryCategoryConfig]
	@Relationship(deleteRule: .cascade)
	var lists: [ReminderList]
	
	init(summaryCategories: [SummaryCategoryConfig] = [.today, .scheduled, .all, .completed],
		lists: [ReminderList] = []) {
		self.summaryCategories = summaryCategories
		self.lists = lists
	}
}

// - types/computed
extension ReminderModel {
	enum SummaryCategory: CaseIterable, Codable, Identifiable {
		var id: Self { return self }
		
		case today
		case scheduled
		case all
		case completed
	}
	
	struct SummaryCategoryConfig: Codable, Identifiable {
		static let today: SummaryCategoryConfig = .init(id: .today, isVisible: true)
		static let scheduled: SummaryCategoryConfig  = .init(id: .scheduled, isVisible: true)
		static let all: SummaryCategoryConfig = .init(id: .all, isVisible: true)
		static let completed: SummaryCategoryConfig = .init(id: .completed, isVisible: true)
		
		var id: SummaryCategory
		var isVisible: Bool
	}
	
	var hasVisibleCategories: Bool { summaryCategories.firstIndex(where: {$0.isVisible}) != nil }
	
	func reminders(for category: SummaryCategory) -> [Reminder] {
		return lists.reduce(into: [Reminder]()) { (partialResult, next) in
			let listRem = next.reminders
			switch category {
			case .all:
				partialResult += Array(listRem)
				
			case .completed:
				partialResult += listRem.filter({$0.isCompleted})
				
			case .scheduled:
				partialResult += listRem.filter({$0.notifyOn != nil})
				
			case .today:
				partialResult += listRem.filter({$0.isCompleted == false})
			}
		}
	}	
}

// - temporary debugging data
extension ReminderModel{
	static var debugReminderListDefault: ReminderList {
		let ret = ReminderList.default
		ret.append(.init(list: ret, title: "Take out dogs"))
		ret.append(.init(list: ret, title: "Read about SwiftUI", notes: "...carefully", notifyOn: .dateTime(dateTime: Date().addingTimeInterval(60 * 60 * 12), repeats: .daily), priority: .high))
		ret.append(.init(list: ret, title: "Car work", priority: .medium))
		ret.append(.init(list: ret, title: "Past Reminder", priority: .low, completedOn: Date()))
		return ret
	}
	
	static var debugReminderListAlt: ReminderList {
		let ret = ReminderList(name: "Alternative", color: .green)
		ret.append(.init(list: ret, title: "Quit Job", priority: .medium))
		ret.append(.init(list: ret, title: "Learn an Instrument", priority: .high))
		ret.append(.init(list: ret, title: "Reflect on Life", completedOn: Date()))
		return ret
	}

	static var debugReminderModelDefault: ReminderModel {
		return .init(lists: [debugReminderListDefault, debugReminderListAlt])
	}
}
