//
//  ReminderStore.swift
//  RReminders
//
//  Created by Francis Grolemund on 4/30/25.
//

import Foundation
import SwiftData

// - the reminder store saves all reminders in their respective lists along with app configuration
// - this is designed to be used like a singleton in the app despite the fact that SwiftData doesn't
//   naturally do singletons.  The goal is to get the automatic persistence for all the relationships
//   by interfacing with SwiftData in one place.
// - NOTE: I learned a bit into this project that SwiftData Array attributes don't retain their sort
//         order, so there are a few places in the model where I've had to reintroduce those guarantees
//         manually and at the expense of performance.  I'm not thrilled about this compromise.
@Model
final class ReminderStore {
	var summaryCategories: [SummaryCategoryConfig] {
		get { rawCat.sorted(by: {$0.arrayOrder < $1.arrayOrder}) }
		
		set {
			guard newValue.count == SummaryCategory.allCases.count else { return }
			var tmp = newValue
			for i in 0..<tmp.count {
				tmp[i].arrayOrder = i
			}
			rawCat = tmp
		}
	}
	
	var lists: [ReminderList] {
		get { rawLists.sorted(by: { $0.arrayOrder < $1.arrayOrder } ) }
		set {
			for (i, v) in newValue.enumerated() {
				v.arrayOrder = i
			}
			rawLists = newValue
		}
	}
	
	init(lists: [ReminderList] = []) {
		self.rawCat = [.today, .scheduled, .all, .completed]
		self.rawLists = lists
	}
	
	// ...preserve array order that's not guaranteed by SwiftData
	private var rawCat: [SummaryCategoryConfig]
	
	@Relationship(deleteRule: .cascade)
	private var rawLists: [ReminderList]
}


// - types/computed
extension ReminderStore {
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
		
		init(id: SummaryCategory, isVisible: Bool) {
			self.id = id
			self.arrayOrder = 0
			self.isVisible = isVisible
		}
		
		var id: SummaryCategory
		var arrayOrder: Int
		var isVisible: Bool
	}
}

