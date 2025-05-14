//
//  VReminderListItem.swift
//  RReminders
// 
//  Created on 2/27/25
//  Copyright © 2025 Francis Grolemund.  All rights reserved. 
//

import SwiftUI

struct VReminderListItem: View {
	var reminder: VMReminder
	@State private var title: String
	@State private var notes: String
	@FocusState private var focused: FocusField?
	@State private var isShowingDetails: Bool = false
	@State private var isCompleted: Bool
	@Binding var focusedReminder: VMReminder?
	private var titleReturn: ReturnBlock?
	private let allowCompletion: Bool
	
	fileprivate enum FocusField: Hashable {
		case title
		case notes
	}
		
	typealias ReturnBlock = (_ reminder: VMReminder) -> Void
	init(reminder: VMReminder, focusedReminder: Binding<VMReminder?>, allowCompletion: Bool = true, titleReturn: ReturnBlock? = nil) {
		self.reminder = reminder
		self._focusedReminder = focusedReminder
		self.titleReturn = titleReturn
		self._title = State(initialValue: reminder.title)
		self._notes = State(initialValue: reminder.notes ?? "")
		self._isCompleted = State(initialValue: reminder.isCompleted)
		self.allowCompletion = allowCompletion
	}
	
    var body: some View {
		HStack(alignment: .top) {
			ReminderToggle(isOn: $isCompleted, allowCompletion: allowCompletion)
				.foregroundStyle(isCompleted ? Color.accentColor : Color.secondary)
				.padding(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0))
				.onChange(of: isCompleted, {
					Task {
						try? await Task.sleep(for: .seconds(2))
						guard !Task.isCancelled, isCompleted != reminder.isCompleted else { return }
						withAnimation {
							reminder.isCompleted = isCompleted
						}
					}
				})
							
			VStack(spacing: 4) {
				HStack {
					HStack(spacing: 4) {
						Text(priorityText)
							.foregroundStyle(Color.accentColor)
						
						let dimTitle = reminder.isCompleted
						TextField("", text: $title)
							.focused($focused, equals: .title)
							.foregroundStyle(dimTitle ? Color.secondary : Color.primary)
							.onKeyPress(.return) {
								guard let titleReturn, reminder.allowCommit else { return .handled }
								reminder.save()
								titleReturn(reminder)
								return .handled
							}
					}
					
					Spacer()
					InfoButton {
						if reminder.isPending, !reminder.allowCreation {
							reminder.title = "New Reminder"
							reminder.save()
						}
						isShowingDetails = true
						Task { self.title = reminder.title }
					}
					.foregroundStyle(.tint)
					.visible(isFocused)
				}
				
				if isFocused || notes != "" {
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
		.onChange(of: [title, notes], { _, newValue in
			reminder.title = newValue[0]
			reminder.notes = newValue[1].isEmpty ? nil : newValue[1]
		})
		.onChange(of: focused, { _, newValue in
			guard newValue == nil, reminder.isModified else { return }
			if reminder.allowCommit {
				reminder.save()
			} else {
				reminder.discard()
			}
		})
		.onAppear {
			if focusedReminder == reminder {
				focusedReminder = nil
				focused = .title
			}
		}
		.sheet(isPresented: $isShowingDetails) {
			VReminderDetails(reminder: reminder)
		}
		.toolbar {
			if isFocused {
				VDoneButton {
					if reminder.allowCommit {
						reminder.save()
					} else {
						reminder.discard()
					}
					focused = nil
				}
			}
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
	
	private var isFocused: Bool { focused != nil }
}


#Preview {
	VStack {
		Divider()
		VReminderListItem(reminder:  _PCReminderListDefault[1], focusedReminder: .constant(nil))
		Divider()
		
		VReminderListItem(reminder: _PCReminderListDefault[2], focusedReminder: .constant(nil))
		Divider()
		
		VReminderListItem(reminder: _PCReminderListDefault[0], focusedReminder: .constant(nil))
		Divider()
		
		VReminderListItem(reminder: _PCReminderListAlt[1], focusedReminder: .constant(nil), allowCompletion: false)
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
	let allowCompletion: Bool
	
	var body: some View {
		Button {
			guard allowCompletion else { return }
			isOn.toggle()
		} label: {
			ZStack {
				if allowCompletion {
					Circle()
						.stroke(lineWidth: 1)
				} else {
					Circle()
						.stroke(Color.gray, style: StrokeStyle(dash: [2]))
				}
					
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
