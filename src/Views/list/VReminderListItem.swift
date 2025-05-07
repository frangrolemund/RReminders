//
//  VReminderListItem.swift
//  RReminders
// 
//  Created on 2/27/25
//  Copyright © 2025 Francis Grolemund.  All rights reserved. 
//

import SwiftUI

struct VReminderListItem: View {
	@Bindable var reminder: VMReminder
	@State private var title: String
	@State private var notes: String
	private let isSelected: Bool
	@FocusState private var focused: FocusField?
	@State private var isShowingDetails: Bool = false
	
	fileprivate enum FocusField: Hashable {
		case title
		case notes
	}
		
	init(reminder: VMReminder, isSelected: Bool = false) {
		self.reminder = reminder
		self._title = State(initialValue: reminder.title)
		self._notes = State(initialValue: reminder.notes ?? "")
		self.isSelected = isSelected
	}
	
    var body: some View {
		HStack(alignment: .top) {
			ReminderToggle(isOn: $reminder.isCompleted)
				.foregroundStyle(reminder.isCompleted ? Color.accentColor : Color.secondary)
				.padding(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0))
							
			VStack(spacing: 4) {
				HStack {
					HStack(spacing: 4) {
						Text(priorityText)
							.foregroundStyle(Color.accentColor)
						
						let dimTitle = reminder.isCompleted && !isSelected
						TextField("", text: $title)
							.focused($focused, equals: .title)
							.foregroundStyle(dimTitle ? Color.secondary : Color.primary)
					}
					
					Spacer()
					InfoButton {
						isShowingDetails = true
					}
					.foregroundStyle(.tint)
					.visible(focused != nil)
				}
				
				if focused != nil || notes != "" {
					TextField("Add Note", text: $notes)
						.focused($focused, equals: .notes)
						.frame(maxWidth: .infinity, alignment: .leading)
						.foregroundStyle(.secondary)
				}
				
				if let remindOn = reminder.notifyOn {
					ReminderRemindOnText(remindOn: remindOn)
						.frame(maxWidth: .infinity, alignment: .leading)
						.foregroundStyle(.secondary)
				}
			}
			.padding([.top, .bottom], 5)
		}
		.contentShape(Rectangle())
		.onChange(of: reminder.isModified) { _, newValue in
			title = reminder.title
			notes = reminder.notes ?? ""
		}
		.onAppear {
			if isSelected {
				focused = .title
			}
		}
		.sheet(isPresented: $isShowingDetails) {
			VReminderDetails(reminder: reminder)
		}
    }
    
	private var priorityText: String {
		switch (reminder.priority) {
		case .none:
			return ""
			
		case .low:
			return "!"
			
		case .medium:
			return "!!"
			
		case .high:
			return "!!!"
		}
	}
}


#Preview {
	VStack {
		Divider()
		VReminderListItem(reminder:  _PCReminderListDefault[1])
		Divider()
		
		VReminderListItem(reminder: _PCReminderListDefault[2])
		Divider()
		
		VReminderListItem(reminder: _PCReminderListDefault[3])
		Divider()
		
		VReminderListItem(reminder: _PCReminderListAlt[1], isSelected: true)
	}
	.padding([.leading, .trailing], 20)
}


fileprivate struct InfoButton: View {
	let action: () -> Void
	
	var body: some View {
		Button {
			action()
		} label: {
			Image(systemName: "info.circle")
				.resizable()
				.frame(width: 22, height: 22)
		}
		.buttonStyle(.plain)
	}
}


fileprivate struct ReminderToggle: View {
	@Binding var isOn: Bool
	
	var body: some View {
		Button {
			isOn.toggle()
		} label: {
			ZStack {
				Circle()
					.stroke(lineWidth: 1)
					
				if isOn {
					Circle()
						.fill()
						.frame(width: 18, height: 18)
						
				}
			}
		}
		.buttonStyle(.plain)
		.frame(width: 22, height: 22)

	}
}

fileprivate struct ReminderRemindOnText: View {
	var remindOn: Reminder.RemindOn

	var body: some View {
		let (dateText, repTmp) = remindOnText
		if let repeatsOn = repTmp {
			Text(dateText + " ") + Text(Image(systemName: "repeat")) + Text(" " + repeatsOn)
		} else {
			Text(dateText)
		}
	}
	
	private var remindOnText: (String, String?) {
		switch remindOn {
		case .date(let dt, let repeats):
			return (DateFormatter.localizedString(from: dt, dateStyle: .short, timeStyle: .none),
				repeats.longDescription)

		case .dateTime(let dt, let repeats):
			return (DateFormatter.localizedString(from: dt, dateStyle: .short, timeStyle: .short),
				repeats.longDescription)
		}
	}
}
