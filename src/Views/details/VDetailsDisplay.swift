//
//  VDetailsDisplay.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/15/25.
//

import Foundation
import SwiftUI

struct VDetailsDisplay: View {
	@Bindable var reminder: VMReminder
	@State private var notes: String
	@State private var notifyDate: Date?
	@State private var notifyTime: Date?
	@State private var dExpanded: Bool = false
	@State private var tExpanded: Bool = false
	@State private var repeats: Reminder.Repeats
	@State private var list: VMReminderList
	private let style: Style
	
	enum Style {
		case full
		case new
	}
	
	init(reminder: VMReminder, style: Style = .full) {
		self.reminder   = reminder
		self.style      = style
		let nDate       = reminder.notifyOn?.date
		self.notifyDate = nDate
		let nTime       = reminder.notifyOn?.time
		self.notifyTime = nTime
		self.dExpanded  = (nDate != nil && nTime == nil)
		self.tExpanded  = (nTime != nil)
		self.repeats    = .never
		self._list = .init(initialValue: reminder.list)
		self._notes = State(initialValue: reminder.notes ?? "")
	}
	
    var body: some View {
		List {
			if style == .full {
				Section {
					TextField("Title", text: $reminder.title)
					TextField("Notes", text: $notes, axis: .vertical)
				}
			}
			
			Section {
				VDetailsDateField(date: $notifyDate, isExpanded: $dExpanded)
				VDetailsTimeField(time: $notifyTime, isExpanded: $tExpanded)
			}
			
			if notifyDate != nil {
				Section {
					NavigationLink {
						VRepeatsSelection(repeats: $repeats)
						
					} label: {
						VRepeatsField(repeats: $repeats)
					}
					
					if (repeats != .never) {
						NavigationLink {
							VEndRepeatsSelection(repeats: $repeats)
						} label: {
							HStack {
								Text("End Repeat")
								Spacer()
								Text(self.endRepeatsDescription)
							}
						}
					}
				}
			}
			
			Section {
				VDetailsPriorityField(priority: $reminder.priority)
				if style == .full {
					VDetailsListField(list: $list)
				}
			}
		}
		.listSectionSpacing(15)
		.onChange(of: notes) { _, newValue in
			reminder.notes = newValue != "" ? newValue : nil
		}
		.onChange(of: [notifyDate, notifyTime]) { oldValue, _ in
			recomputeNotify(oldDate: oldValue[0], oldTime: oldValue[1])
		}
		.onChange(of: repeats, {
			recomputeNotify(oldDate: notifyDate, oldTime: notifyTime)
		})
		.onChange(of: [dExpanded, tExpanded]) {oldValue, _ in
			if !oldValue[0] && dExpanded {
				tExpanded = false
			} else if (!oldValue[1] && tExpanded) {
				dExpanded = false
			}
		}
		.onChange(of: list) { _, newValue in
			reminder.list = newValue
		}
    }
}


#Preview("Full") {
	NavigationStack {
		VDetailsDisplay(reminder: _PCReminderListDefault[1])
	}
}

#Preview("New") {
	NavigationStack {
		VDetailsDisplay(reminder: _PCReminderListDefault[1], style: .new)
	}
}



private extension VDetailsDisplay {
	private func recomputeNotify(oldDate: Date?, oldTime: Date?) {
		if (oldDate == nil && oldTime == nil && (notifyDate != nil || notifyTime != nil)) {
			dExpanded = (notifyDate != nil)
			tExpanded = (notifyTime != nil)
			if (notifyTime != nil && notifyDate == nil) {
				notifyDate = .now
			}
			
		} else if (notifyDate == nil && notifyTime == nil && (oldDate != nil || oldTime != nil)) {
			dExpanded = false
			tExpanded = false
			
		} else if (notifyDate == nil && notifyTime != nil) {
			notifyTime = nil
			dExpanded = false
			tExpanded = false
		}

		guard let notifyDate else {
			reminder.notifyOn = nil
			return
		}
		
		if let notifyTime {
			reminder.notifyOn = .dateTime(dateTime: notifyDate.replacingTime(with: notifyTime), repeats: repeats)
		} else {
			reminder.notifyOn = .date(date: notifyDate, repeats: repeats)
		}
	}
	
	private var endRepeatsDescription: String {
		guard repeats != .never else { return "" }
		guard let ends = repeats.ends else { return "Never" }
		
		let df = DateFormatter()
		df.setLocalizedDateFormatFromTemplate("EEE, MMM d, yyyy")
		return df.string(from: ends)
	}
}
