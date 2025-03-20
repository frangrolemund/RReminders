//
//  VSummaryListItem.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/9/25.
//

import SwiftUI

struct VSummaryListItem: View {
	let list: ReminderList
	
    var body: some View {
		HStack(spacing: 10) {
			Image(systemName: "list.bullet.circle.fill")
				.resizable()
				.reminderIconSized()
				.foregroundStyle(list.color.uiColor)
				
			Text(list.name)
				.foregroundStyle(.primary)
			
			Spacer()
			
			Text("\(list.count)")
		}
		.padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
    }
}

#Preview {
	List {
		VSummaryListItem(list: _PCReminderListDefault)
		VSummaryListItem(list: _PCReminderListAlt)
	}
}
