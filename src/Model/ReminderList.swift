//
//  ReminderList.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/11/25.
//

import Foundation
import SwiftData

// - an authoritative list of unique reminders
@Model
class ReminderList: Identifiable, AnyObject {
	static var `default`: ReminderList {
		.init(name: "Reminders", color: .blue)
	}

	@Attribute(.unique) private(set) var id: UUID
	var name: String
	var color: ReminderList.Color
	
	@Relationship(deleteRule: .cascade, inverse: \Reminder.list)
	var reminders: [Reminder] {
		didSet {
			ensureLinkage()
			self.sortedReminders = nil
		}
	}
	var showCompleted: Bool
	var sortOrder: SortOrder {
		didSet { self.sortedReminders = nil }
	}
	
	init(id: UUID = .init(),
		name: String,
		color: ReminderList.Color = .blue,
		reminders: [Reminder] = [],
		showCompleted: Bool = false,
		sortOrder: SortOrder = .manual) {
		self.id = id
		self.name = name
		self.color = color
		self.reminders = reminders
		self.showCompleted = showCompleted
		self.sortOrder = sortOrder
		self.ensureLinkage()
	}
			
	subscript(index: Int) -> Reminder {
		get { sortedReminders[index] }
		set {
			let rid = sortedReminders[index].id
			if let mIdx = reminders.firstIndex(where: { r in r.id == rid }) {
				reminders[mIdx] = newValue
			}
		}
	}
	
	func append(_ reminder: Reminder) {
		reminders.append(reminder)
	}
	
	@Transient private var _sortedReminders: [Reminder]?	// cache
}


// - types/computed
extension ReminderList {
	enum Color: Codable {
		case red
		case orange
		case yellow
		case green
		case blue
		case purple
		case brown
	}
	
	enum SortOrder : Codable {
		case manual
		case dueDate
		case creationDate
		case priority
		case title
	}
	
	var startIndex: Int { reminders.startIndex }
	var endIndex: Int { reminders.endIndex }
	var count: Int { reminders.count }
	
	private func ensureLinkage() {
		reminders.forEach { rem in
			if rem.list == nil {
					rem.list = self
			}
		}
	}

	private var sortedReminders: [Reminder] {
		if let ret = _sortedReminders { return ret }
		
		let resorted: [Reminder]
		switch sortOrder {
		case .manual:
			resorted = reminders
		
		case .dueDate:
			resorted = reminders.sorted(by: { r1, r2 in
				r1.dueDate < r2.dueDate
			})
			
		case .creationDate:
			resorted = reminders.sorted(by: { r1, r2 in
				r1.created < r2.created
			})
			
		case .priority:
			resorted = reminders.sorted(by: { r1, r2 in
				(r1.priority?.rawValue ?? 99) < (r2.priority?.rawValue ?? 99)
			})
			
		case .title:
			resorted = reminders.sorted(by: { r1, r2 in
				r1.title.localizedCompare(r2.title) == .orderedAscending
			})
		}
		
		_sortedReminders = resorted
		return resorted
	}
}
