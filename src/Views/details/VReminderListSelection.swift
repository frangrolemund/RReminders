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
	let isNewItem: Bool
	
	init(reminder: Binding<Reminder>, isNewItem: Bool = false) {
		self._reminder = reminder
		self.isNewItem = isNewItem
	}
	
    var body: some View {
		List {
			Section {
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
						.listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 5, trailing: 20))
				}
			} header: {
				VStack(alignment: .leading, spacing: 40) {
					if isNewItem {
						VStack(alignment: .center) {
						Text("Reminder will be created in \"\(reminder.list.name)\"")
								.font(.headline)
								.fontWeight(.semibold)
								.frame(maxWidth: .infinity)
						}
					}
				
					Text("Local")
						.font(.title3)
						.fontWeight(.semibold)
				}
				.foregroundStyle(Color.primary)
			}
			.listSectionSeparator(.hidden)
		}
		.listStyle(.plain)
		.navigationTitle("List")
		.navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
	@Previewable @State var model: ReminderModel = _PCReminderModel
	VReminderListSelection(reminder: $model.lists[0].reminders[0])
		.environment(model)
}
