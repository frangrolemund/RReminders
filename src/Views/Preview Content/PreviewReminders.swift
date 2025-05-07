//
//  PreviewReminders.swift
//  RReminders
// 
//  Created on 2/28/25
//  Copyright © 2025 Francis Grolemund.  All rights reserved. 
//

import Foundation

let _PCReminderListDefault: VMReminderList = VMReminderStore.debugReminderListDefault

let _PCReminderListAlt: VMReminderList = VMReminderStore.debugReminderListAlt

let _PCReminderModel: VMReminderStore = VMReminderStore.debugReminderModelDefault

let _PCReminderModelNew: VMReminderStore = .init(store: ReminderStore())


// - temporary debugging data
fileprivate extension VMReminderStore {
	static var debugReminderListDefault: VMReminderList {
		debugReminderModelDefault.lists[0]
	}
	
	static var debugReminderListAlt: VMReminderList {
		debugReminderModelDefault.lists[1]
	}

	static var debugReminderModelDefault: VMReminderStore {
		let ret = VMReminderStore(store: ReminderStore())
		let lDef = ret.addReminderList(name: "Reminders", color: .blue)
		lDef.save()
		lDef.addReminder(title: "Take out dogs").save()
		lDef.addReminder(title: "Read about SwiftUI", notes: "...carefully", notifyOn: .dateTime(dateTime: Date().addingTimeInterval(60 * 60 * 12), repeats: .daily), priority: .high).save()
		lDef.addReminder(title: "Car work", priority: .medium).save()
		lDef.addReminder(title: "Past Reminder", priority: .low, completedOn: Date()).save()
	
		let lAlt = ret.addReminderList(name: "Alternative", color: .green)
		lAlt.save()
		lAlt.addReminder(title: "Quit Job", priority: .medium).save()
		lAlt.addReminder(title: "Learn an Instrument", priority: .high).save()
		lAlt.addReminder(title: "Reflect on Life", completedOn: Date()).save()

		return ret
	}
}
