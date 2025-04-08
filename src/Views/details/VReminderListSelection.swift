//
//  VReminderListSelection.swift
//  RReminders
//
//  Created by Francis Grolemund on 4/7/25.
//

import SwiftUI

struct VReminderListSelection: View {
	@Environment(ReminderModel.self) var modelData: ReminderModel
	@Binding var reminderList: ReminderList
	let isNewItem: Bool
	
	init(list: Binding<ReminderList>, isNewItem: Bool = false) {
		self._reminderList = list
		self.isNewItem = isNewItem
	}
	
    var body: some View {
		List {
			Section {
				ForEach(modelData.lists) { list in
					VSummaryListItem(list: list, displayStyle: reminderList.id == list.id ? .check : .none)
						.background {
							Button {
								reminderList = list
							} label: {
								Text("")
							}
						}
						.listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
				}
			} header: {
				VStack(alignment: .leading, spacing: 40) {
					if isNewItem {
						VStack(alignment: .center) {
						Text("Reminder will be created in \"\(reminderList.name)\"")
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
				.padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
			}
			.listSectionSeparator(.hidden, edges: .top)
		}
		.listStyle(.plain)
		.navigationTitle("List")
		.navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
	@Previewable @State var model: ReminderModel = _PCReminderModel
	VReminderListSelection(list: $model.lists[0])
		.environment(model)
}
