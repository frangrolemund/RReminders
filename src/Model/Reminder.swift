//
//  Reminder.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/11/25.
//

import Foundation
import SwiftData

// - reminders are unique instances of a note that are tracked to completion.
@Model
final class Reminder: Identifiable, Equatable {
	static func == (lhs: Reminder, rhs: Reminder) -> Bool {
		return lhs.id == rhs.id &&
				lhs.created == rhs.created &&
				lhs.title == rhs.title &&
				lhs.notes == rhs.notes &&
				lhs.notifyOn == rhs.notifyOn &&
				lhs.priority == rhs.priority &&
				lhs.completedOn == rhs.completedOn
	}

	@Attribute(.unique) private(set) var id: UUID
	private(set) var created: Date
	var title: String { didSet { isModified = true } }
	var notes: String? { didSet { isModified = true } }
	var notifyOn: RemindOn? { didSet { isModified = true } }
	var priority: Priority? { didSet { isModified = true } }
	var completedOn: Date? { didSet { isModified = true } }
	
	// ...convenience reference to the enclosing list
	weak var list: ReminderList!
	
	// ...track this explicitly to support .onChange with this instance
	@Transient var isModified: Bool = false // - not persisted
	
	init(id: UUID = .init(),
		created: String? = nil,
		list: ReminderList,
		title: String,
		notes: String? = nil,
		notifyOn: RemindOn? = nil,
		priority: Priority? = nil,
		completedOn: Date? = nil) {
		self.id = id
		self.created = ISO8601DateFormatter().date(from: created ?? "") ?? Date()
		self.list = list
		self.title = title
		self.notes = notes
		self.notifyOn = notifyOn
		self.priority = priority
		self.completedOn = completedOn
	}
	
	// - add CodingKeys to both encode using non-private names but to also omit the extra @Observable property
	private enum CodingKeys: String, CodingKey {
		case id = "id"
		case created = "created"
		case _title = "title"
		case _notes = "notes"
		case _notifyOn = "notifyOn"
		case _priority = "priority"
		case _completedOn = "completedOn"
	}
}

// - types/computed
extension Reminder {
	var allowCreation: Bool {
		return !(title.trimmingCharacters(in: .whitespacesAndNewlines)).isEmpty && self.list != nil
	}

	var isCompleted: Bool {
		get { completedOn != nil }
		set {
			if newValue {
				completedOn = completedOn == nil ? Date() : completedOn
			} else {
				completedOn = nil
			}
		}
	}
	
	
	var dueDate: Date { notifyOn?.date ?? Date.distantFuture }
	
	
	func cloned() -> Reminder {
		return .init(id: self.id,
				created: self.created.ISO8601Format(),
				list: self.list,
				title: self.title,
				notes: self.notes,
				notifyOn: self.notifyOn,
				priority: self.priority,
				completedOn: self.completedOn)
	}
		
	func update(from other: Reminder) {
		guard self.id == other.id && self != other else { return }
		self.title = other.title
		self.notes = other.notes
		self.notifyOn = other.notifyOn
		self.priority = other.priority
		self.completedOn = other.completedOn
		self.isModified = false
	}


	enum Priority: Int, CaseIterable, Codable, Equatable {
		case low = 0
		case medium = 1
		case high = 2
	}

	enum RemindOn : Codable, Equatable {
		case date(date: Date, repeats: Repeats? = nil)
		case dateTime(dateTime: Date, repeats: Repeats? = nil)
		
		var date: Date {
			switch self {
			case .date(let dt, _):
				return dt
			case .dateTime(let dt, _):
				return dt
			}
		}
		
		var time: Date? {
			switch self {
			case .date(_, _):
				return nil
				
			case .dateTime(let dt, _):
				return dt
			}
		}
	}

	// - the Repeats type behaves like an enum with a common stored
	//   value for an end date that is available across all options.
	struct Repeats: Codable, Identifiable, Equatable {
		let id: Period
		var ends: Date?
		var isNeverEnding: Bool { self.ends == nil }
		
		static let daily = Repeats(id: .daily)
		static let weekdays = Repeats(id: .weekdays)
		static let weekends = Repeats(id: .weekends)
		static let weekly = Repeats(id: .weekly)
		static let biweekly = Repeats(id: .biweekly)
		static let monthly = Repeats(id: .monthly)
		static let every3Months = Repeats(id: .every3Months)
		static let every6Months = Repeats(id: .every6Months)
		static let yearly = Repeats(id: .yearly)
		static let allCases: [Repeats] = { Period.allCases.map( {Repeats(id: $0)} ) }()

		enum Period : Codable, CaseIterable, Identifiable {
			var id: Period { self }
			case daily
			case weekdays
			case weekends
			case weekly
			case biweekly
			case monthly
			case every3Months
			case every6Months
			case yearly
		}
	}
}
