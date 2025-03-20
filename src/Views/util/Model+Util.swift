//
//  Model+Util.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/12/25.
//

import Foundation
import SwiftUI

extension ReminderList.Color {
	var uiColor: SwiftUI.Color {
		switch (self) {
		case .red: return .red
		case .orange: return .orange
		case .yellow: return .yellow
		case .green: return .green
		case .blue: return .blue
		case .purple: return .purple
		case .brown: return .brown
		}
	}
}

extension Reminder.Repeats: CustomStringConvertible {
	var description: String {
		switch self {
		case .daily: return "Daily"
		case .weekdays: return "Weekdays"
		case .weekends: return "Weekends"
		case .weekly: return "Weekly"
		case .biweekly: return "Biweekly"
		case .monthly: return "Monthly"
		case .every3Months: return "Every 3 Months"
		case .every6Months: return "Every 6 Months"
		case .yearly: return "Yearly"
		}
	}
	
	var longDescription: String {
		if case .biweekly = self {
			return "Every 2 weeks"
		}
		return self.description
	}
}

extension ReminderModel.SummaryCategory: CustomStringConvertible {
	var description: String {
		switch self {
		case .today: return "Today"
		case .scheduled: return "Scheduled"
		case .all: return "All"
		case .completed: return "Completed"
		}
	}
	
	var icon: VCategoryBadge { VCategoryBadge(self)	}
}
