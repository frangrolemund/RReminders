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
	@State private var canSave: Bool
	
	init(reminder: VMReminder) {
		self.reminder = reminder
		self._canSave = State(initialValue: reminder.allowCommit)
	}

    var body: some View {
		NavigationStack {
			VDetailsDisplay(reminder: reminder)
				.navigationBarTitleDisplayMode(.inline)
				.navigationTitle("Details")
				.toolbar {
					ToolbarItem(placement: .topBarLeading) {
						VCancelButton {
							if reminder.isModified {
								isConfirmCancel = true
							} else {
								dismiss()
							}
						}
					}
					
					ToolbarItem(placement: .topBarTrailing) {
						VDoneButton {
							reminder.save()
							dismiss()
						}
						.disabled(!canSave)
					}
				}
				.confirmationDialog("", isPresented: $isConfirmCancel, titleVisibility: .hidden, actions: {
					Button("Discard Changes", role: .destructive) {
						dismiss()
						Task { reminder.revert() }
					}
				})
				.onChange(of: reminder.title) {
					canSave = reminder.allowCommit
				}
		}
    }
}

#Preview {
	VReminderDetails(reminder: _PCReminderListDefault[0])
}
