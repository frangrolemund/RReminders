//
//  VReminderListSelection.swift
//  RReminders
//
//  Created by Francis Grolemund on 4/7/25.
//

import SwiftUI

struct VReminderListSelection: View {
	@Environment(ReminderModel.self) var modelData: ReminderModel
	@Binding var reminder:Reminder
	
    var body: some View {
		Section("Local") {
			List {
				ForEach(modelData.lists) { list in
					VSummaryListItem(list: list, displayStyle: reminder.list?.id == list.id ? .check : .none)
						.background {
							Button {
								print("Set list to -> \(list.id)")
								reminder.list = list
							} label: {
								Text("")
							}
						}
				}
			}
			.listStyle(.plain)
		}
		.navigationTitle("List")
		.navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
	@Previewable @State var model: ReminderModel = _PCReminderModel
	VReminderListSelection(reminder: $model.lists[0].reminders[0])
		.environment(model)
}
