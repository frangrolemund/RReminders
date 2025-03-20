//
//  Date+Util.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/16/25.
//

import Foundation

extension Set<Calendar.Component> {
	static var preciseDay: Set<Calendar.Component> {
		return [.year, .month, .day]
	}
}

extension Date {
	func replacingTime(with date: Date) -> Date {
		let dcTime = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
		return Calendar.current.date(bySettingHour: dcTime.hour ?? 0,
				minute: dcTime.minute ?? 0,
				second: dcTime.second ?? 0, of: self) ?? self
	}
}
