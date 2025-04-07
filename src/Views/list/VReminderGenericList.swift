//
//  VReminderGenericList.swift
//  RReminders
// 
//  Created on 3/1/25
//  Copyright © 2025 Francis Grolemund.  All rights reserved. 
//

import SwiftUI

struct VReminderGenericList: View {
	@Bindable var list: ReminderList

    var body: some View {
		List {
			Text(list.name)
				.font(.largeTitle)
				.bold()
				.foregroundStyle(list.color.uiColor)
				.selectionDisabled()
				.listRowSeparator(.hidden)
		
			ForEach(list.reminders) { (reminder: Reminder) in
				VReminderListItem(reminder: reminder)
					.tag(reminder.id)
			}
		}
		.listStyle(.plain)
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem {
				VListInfoMenu(list: list)
			}
		}
    }
}

#Preview {
	NavigationStack {
		VReminderGenericList(list: _PCReminderListDefault)
	}
}
