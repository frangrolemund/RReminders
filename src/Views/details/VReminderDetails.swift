//
//  VReminderDetails.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/15/25.
//

import SwiftUI

struct VReminderDetails: View {
	@Environment(\.dismiss) var dismiss
	@Bindable var reminder: Reminder
	@State private var pendingReminder: Reminder
	@State private var isConfirmCancel: Bool = false
	
	init(reminder: Reminder) {
		self.reminder = reminder
		self._pendingReminder = State(initialValue: reminder.cloned())
	}

    var body: some View {
		NavigationStack {
			VDetailsDisplay(reminder: pendingReminder)
				.navigationBarTitleDisplayMode(.inline)
				.navigationTitle("Details")
				.toolbar {
					ToolbarItem(placement: .topBarLeading) {
						Button("Cancel") {
							if pendingReminder.isModified {
								isConfirmCancel = true
							} else {
								dismiss()
							}
						}
					}
					
					ToolbarItem(placement: .topBarTrailing) {
						Button("Done") {
							reminder.update(from: pendingReminder)
							dismiss()
						}
						.fontWeight(.semibold)
					}
				}
				.confirmationDialog("", isPresented: $isConfirmCancel, titleVisibility: .hidden, actions: {
					Button("Discard Changes", role: .destructive) {
						dismiss()
					}
				})
		}
    }
}

#Preview {
	VReminderDetails(reminder: _PCReminderListDefault[0])
}
