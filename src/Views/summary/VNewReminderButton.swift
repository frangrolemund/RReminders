//
//  VNewReminderButton.swift
//  RReminders
//
//  Created by Francis Grolemund on 5/20/25.
//


import SwiftUI

struct VNewReminderButton: View {
	let action: () -> Void
	
	init(action: @escaping () -> Void) {
		self.action = action
	}
	
	var body: some View {
		Button {
			action()
		} label: {
			HStack(spacing: 10) {
				Circle()
					.reminderIconSized(iconDimension: 25)
					.overlay {
						Image(systemName: "plus")
							.foregroundStyle(.white)
					}
				Text("New Reminder")
			}
			.bold()
		}
	}
}
