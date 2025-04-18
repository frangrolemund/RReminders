//
//  VReminderNew.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/26/25.
//

import SwiftUI

struct VReminderNew: View {
	@Environment(\.modelContext) var modelContext
	@Environment(\.dismiss) var dismiss
	var modelData: ReminderModel
	@State private var reminder: Reminder
	@State private var isConfirmCancel: Bool = false
	@State private var list: ReminderList
	
	init(model: ReminderModel, list: ReminderList) {
		self.modelData = model
		self._list = .init(initialValue: list)
		self._reminder = .init(initialValue: Reminder(list: ReminderList(name: ""), title: ""))
	}
	
    var body: some View {
		NavigationStack {
			VReminderNewDisplay(reminder: $reminder, list: $list)
				.toolbar {
					ToolbarItem(placement: .topBarLeading) {
						Button {
							if reminder.allowCreation {
								isConfirmCancel = true
							} else {
								dismiss()
							}
						} label: {
							Text("Cancel")
						}
					}

					ToolbarItem(placement: .topBarTrailing) {
						Button {
							let rem = reminder.cloned()
							list.append(rem)
							try? modelContext.save()
							dismiss()
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
						dismiss()
					}
				}
				.padding(.top, -20)
		}
    }
}


#Preview {
	@Previewable @State var modelData: ReminderModel = _PCReminderModel
	return VReminderNew(model: modelData, list: modelData.lists.first!)
		.environment(modelData)
}

