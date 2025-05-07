//
//  VReminderNew.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/26/25.
//

import SwiftUI

struct VReminderNew: View {
	@Environment(\.dismiss) var dismiss
	var modelData: VMReminderStore
	@State private var reminder: VMReminder
	@State private var isConfirmCancel: Bool = false
	@State private var list: VMReminderList
	
	init(model: VMReminderStore, list: VMReminderList) {
		self.modelData = model
		self._list = .init(initialValue: list)
		self._reminder = .init(initialValue: list.addReminder())
	}
	
    var body: some View {
		NavigationStack {
			VReminderNewDisplay(reminder: $reminder, list: $list, addAction: {
				saveDismiss()
			})
				.toolbar {
					ToolbarItem(placement: .topBarLeading) {
						Button {
							if reminder.allowCreation {
								isConfirmCancel = true
							} else {
								revertDismiss()
							}
						} label: {
							Text("Cancel")
						}
					}

					ToolbarItem(placement: .topBarTrailing) {
						Button {
							saveDismiss()
						} label: {
							Text("Add")
								.bold()
						}
						.disabled(!reminder.allowCreation)
					}
				}
				.navigationTitle("New Reminder")
				.navigationBarTitleDisplayMode(.inline)
				.confirmationDialog("", isPresented: $isConfirmCancel, titleVisibility: .hidden) {
					Button("Discard Changes", role: .destructive) {
						revertDismiss()
					}
				}
				.padding(.top, -20)
				.onChange(of: list) { _, newValue in
					reminder.list = newValue
				}
		}
    }
}

extension VReminderNew {
	private func saveDismiss() {
		reminder.save()
		dismiss()
	}
	
	private func revertDismiss() {
		reminder.revert()
		dismiss()
	}
}


#Preview {
	@Previewable @State var modelData: VMReminderStore = _PCReminderModel
	return VReminderNew(model: modelData, list: modelData.lists.first!)
		.environment(modelData)
}

