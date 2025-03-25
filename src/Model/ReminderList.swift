//
//  ReminderList.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/11/25.
//

import Foundation
import SwiftData

// - reminder lists are unique groups of unique reminders and permit basic iteration
protocol ReminderListDisplayable: RandomAccessCollection, AnyObject, Identifiable, Observable {
	associatedtype Index = Int
	
	var id: UUID { get }
	subscript(index: Int) -> Reminder { get }
}


// - an authoritative list of unique reminders
@Model
class ReminderList: Identifiable, ReminderListDisplayable, MutableCollection {
	static var `default`: ReminderList {
		.init(name: "Reminders", color: .blue)
	}

	@Attribute(.unique) private(set) var id: UUID
	var name: String
	var color: ReminderList.Color
	
	@Relationship(deleteRule: .cascade)
	private var manualReminders: [Reminder] {
		didSet { self.sortedReminders = nil }
	}
	var showCompleted: Bool
	var sortOrder: SortOrder {
		didSet { self.sortedReminders = nil }
	}
	
	@Transient private var sortedReminders: [Reminder]?	// cache
		
	init(id: UUID = .init(),
		name: String,
		color: ReminderList.Color = .blue,
		reminders: [Reminder] = [],
		showCompleted: Bool = false,
		sortOrder: SortOrder = .manual) {
		self.id = id
		self.name = name
		self.color = color
		self.manualReminders = reminders
		self.showCompleted = showCompleted
		self.sortOrder = sortOrder
	}
		
	subscript(index: Int) -> Reminder {
		get { reminders[index] }
		set {
			let tmp = reminders
			let rid = tmp[index].id
			if let mIdx = manualReminders.firstIndex(where: { r in
				r.id == rid
			}) {
				manualReminders[mIdx] = newValue
			}
		}
	}
	
	func append(_ reminder: Reminder) {
		manualReminders.append(reminder)
	}
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

	private var reminders: [Reminder] {
		if let ret = sortedReminders { return ret }
		
		let resorted: [Reminder]
		switch sortOrder {
		case .manual:
			resorted = manualReminders
		
		case .dueDate:
			resorted = manualReminders.sorted(by: { r1, r2 in
				r1.dueDate < r2.dueDate
			})
			
		case .creationDate:
			resorted = manualReminders.sorted(by: { r1, r2 in
				r1.created < r2.created
			})
			
		case .priority:
			resorted = manualReminders.sorted(by: { r1, r2 in
				(r1.priority?.rawValue ?? 99) < (r2.priority?.rawValue ?? 99)
			})
			
		case .title:
			resorted = manualReminders.sorted(by: { r1, r2 in
				r1.title.localizedCompare(r2.title) == .orderedAscending
			})
		}
		
		sortedReminders = resorted
		return resorted
	}
}
