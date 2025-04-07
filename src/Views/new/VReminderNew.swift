//
//  VReminderNew.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/26/25.
//

import SwiftUI

struct VReminderNew: View {
	@Environment(\.dismiss) var dismiss
	var modelData: ReminderModel
	@State private var reminder: Reminder
	
	init(model: ReminderModel, list: ReminderList) {
		self.modelData = model
		self._reminder = .init(initialValue: Reminder(list: list, title: ""))
	}
	
    var body: some View {
		NavigationStack {
			VReminderNewDisplay(reminder: $reminder)
				.toolbar {
					ToolbarItem(placement: .topBarLeading) {
						Button {
							dismiss()
						} label: {
							Text("Cancel")
						}
					}

					ToolbarItem(placement: .topBarTrailing) {
						Button {
							dismiss()
						} label: {
							Text("Add")
						}
						.disabled(!reminder.allowCreation)
					}
				}
		}
    }
}


#Preview {
	@Previewable @State var modelData: ReminderModel = _PCReminderModel
	return VReminderNew(model: modelData, list: modelData.lists.first!)
		.environment(modelData)
}

