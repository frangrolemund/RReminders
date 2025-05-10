//
//  VReminderGenericList.swift
//  RReminders
// 
//  Created on 3/1/25
//  Copyright © 2025 Francis Grolemund.  All rights reserved. 
//

import SwiftUI

struct VReminderGenericList: View {
	@Bindable var list: VMReminderList
	@State var toFocus: VMReminder?

    var body: some View {
		ZStack {
			List {
				Text(list.name)
					.font(.largeTitle)
					.bold()
					.foregroundStyle(list.color.uiColor)
					.selectionDisabled()
					.listRowSeparator(.hidden)
				
				ForEach(list.reminders) { (reminder: VMReminder) in
					VReminderListItem(reminder: reminder, pendingReminder: $toFocus, titleReturn: { reminder in
						if let idx = list.reminders.firstIndex(of: reminder) {
							toFocus = list.insertReminder(at: idx + 1)
						}
					})
					.tag(reminder.id)
				}
			}
			.listStyle(.plain)
			.navigationBarTitleDisplayMode(.inline)
			.onTapGesture {
				managePendingReminder()
			}
			
			VStack(alignment: .leading) {
				Spacer()
				HStack {
					Button {
						managePendingReminder()
					} label: {
						VNewReminderButtonLabel()
					}
					.foregroundStyle(list.color.uiColor)
					Spacer()
				}
				.padding()
			}
			.visible(!list.hasPendingReminder)
		}
		.toolbar {
			ToolbarItem {
				VListInfoMenu(list: list)
			}
		}
		.onDisappear {
			list.discardPendingReminder()
		}
    }
}

#Preview {
	NavigationStack {
		VReminderGenericList(list: _PCReminderListDefault)
	}
}

extension VReminderGenericList {
	private func managePendingReminder() {
		if list.hasPendingReminder {
			list.discardPendingReminder()
		} else {
			toFocus = list.addPendingReminder()			
		}
	}
}
