//
//  Reminder.swift
//  RReminders
//
//  Created by Francis Grolemund on 4/30/25.
//

import Foundation
import SwiftData

// - reminders are unique instances of a note that are tracked to completion.
@Model
final class Reminder: Identifiable {
	@Attribute(.unique) private(set) var id: UUID
	var arrayOrder: Int		// - used by the ReminderList to preserve ordering
	private(set) var created: Date
	var title: String
	var notes: String?
	var notifyOn: RemindOn?
	var priority: Priority?
	var completedOn: Date?
	
	var list: ReminderList?
	
	init(id: UUID = .init(),
		created: Date? = nil,
		title: String,
		notes: String? = nil,
		notifyOn: RemindOn? = nil,
		priority: Priority? = nil,
		completedOn: Date? = nil,
		list: ReminderList? = nil) {
		self.id = id
		self.arrayOrder = 0
		self.created = created ?? Date()
		self.title = title
		self.notes = notes
		self.notifyOn = notifyOn
		self.priority = priority
		self.completedOn = completedOn
		self.list = list
	}
}

// - types/computed
extension Reminder {
	enum Priority: Int, CaseIterable, Codable, Equatable {
		case low = 0
		case medium = 1
		case high = 2
	}

	enum RemindOn : Codable, Equatable {
		// FYI: the 'repeats' associated value was originally an Optional, but SwiftData
		//      was unable to decode that optional successfully once assigned and would
		//      hit an internal breakpoint if the Reminder were accessed later.
		//      Changing it to non-Optional allows it to work
		case date(date: Date, repeats: Repeats = .never)
		case dateTime(dateTime: Date, repeats: Repeats = .never)
		
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
		
		static let never = Repeats(id: .never, ends: nil)
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
			case never
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

