//
//  VSummaryListItem.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/9/25.
//

import SwiftUI

struct VSummaryListItem: View {
	let list: ReminderList
	let displayStyle: DisplayStyle
	
	enum DisplayStyle {
		case none
		case count
		case check
	}

	init(list: ReminderList, displayStyle: DisplayStyle = .none) {
		self.list = list
		self.displayStyle = displayStyle
	}
	
    var body: some View {
		HStack(spacing: 10) {
			Image(systemName: "list.bullet.circle.fill")
				.resizable()
				.reminderIconSized()
				.foregroundStyle(list.color.uiColor)
				
			Text(list.name)
				.foregroundStyle(.primary)
			
			Spacer()
	
			if (displayStyle == .count) {
				Text("\(list.count)")
				
			} else if (displayStyle == .check) {
				Image(systemName: "checkmark")
					.fontWeight(.bold)
					.foregroundStyle(.tint)
			}
		}
		.padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
    }
}

#Preview {
	List {
		VSummaryListItem(list: _PCReminderListDefault, displayStyle: .count)
		VSummaryListItem(list: _PCReminderListAlt)
		VSummaryListItem(list: _PCReminderListDefault, displayStyle: .check)
	}
}
