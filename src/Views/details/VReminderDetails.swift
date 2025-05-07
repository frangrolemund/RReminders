//
//  VReminderDetails.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/15/25.
//

import SwiftUI

struct VReminderDetails: View {
	@Environment(\.dismiss) var dismiss
	@Bindable var reminder: VMReminder
	@State private var isConfirmCancel: Bool = false
	
	init(reminder: VMReminder) {
		self.reminder = reminder
	}

    var body: some View {
		NavigationStack {
			VDetailsDisplay(reminder: reminder)
				.navigationBarTitleDisplayMode(.inline)
				.navigationTitle("Details")
				.toolbar {
					ToolbarItem(placement: .topBarLeading) {
						Button("Cancel") {
							if reminder.isModified {
								isConfirmCancel = true
							} else {
								dismiss()
							}
						}
					}
					
					ToolbarItem(placement: .topBarTrailing) {
						Button("Done") {
							reminder.save()
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
