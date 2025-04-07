//
//  VDetailsListField.swift
//  RReminders
//
//  Created by Francis Grolemund on 4/7/25.
//

import SwiftUI

struct VDetailsListField: View {
	@Binding var reminder: Reminder

    var body: some View {
		NavigationLink(destination: {
			VReminderListSelection(reminder: $reminder)
		}, label: {
			HStack(spacing: 15) {
				Circle()
					.foregroundStyle(reminder.list.color.uiColor)
					.overlay {
						Image(systemName: "list.bullet")
							.resizable()
							.scaledToFit()
							.foregroundStyle(.white)
							.scaleEffect(0.58)
					}
					.reminderDetailsIconSized()
				
				Text("List")
				
				Spacer()
				
				if let list = reminder.list {
					Text(list.name)
						.foregroundStyle(.secondary)
				}
			}
		})
    }
}

#Preview {
	@Previewable @State var reminder: Reminder = _PCReminderListDefault.reminders[0]
	VDetailsListField(reminder: $reminder)
		.padding()
}
