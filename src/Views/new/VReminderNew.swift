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
	@State private var list: ReminderList
	
	init(model: ReminderModel) {
		self.modelData = model
		self.reminder = .init(title: "")
		self.list = model.lists.first ?? ReminderList(name: "New List")
	}
	
    var body: some View {
		NavigationStack {
			VReminderNewDisplay(reminder: $reminder, list: $list)
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
	return VReminderNew(model: modelData)
}

