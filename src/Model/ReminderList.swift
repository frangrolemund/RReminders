//
//  ReminderList.swift
//  RReminders
//
//  Created by Francis Grolemund on 4/30/25.
//

import Foundation
import SwiftData

// - an authoritative list of unique reminders
@Model
class ReminderList: Identifiable, AnyObject {
	@Attribute(.unique) private(set) var id: UUID
	var arrayOrder: Int		// - used by the ReminderStore to preserve ordering
	var name: String
	var color: ReminderList.Color
	
	var reminders: [Reminder] {
		get { rawReminders.sorted(by: {$0.arrayOrder < $1.arrayOrder}) }
		set {
			for (i, v) in newValue.enumerated() {
				v.arrayOrder = i
				v.list = self
			}
			rawReminders = newValue
		}
	}
	var showCompleted: Bool
	var sortOrder: SortOrder
	
	init(id: UUID = .init(),
		name: String,
		color: ReminderList.Color = .blue,
		reminders: [Reminder] = [],
		showCompleted: Bool = false,
		sortOrder: SortOrder = .manual) {
		self.id = id
		self.arrayOrder = 0
		self.name = name
		self.color = color
		self.rawReminders = reminders
		self.showCompleted = showCompleted
		self.sortOrder = sortOrder
	}
	
	@Relationship(deleteRule: .nullify, inverse: \Reminder.list)
	private var rawReminders: [Reminder]
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
}
