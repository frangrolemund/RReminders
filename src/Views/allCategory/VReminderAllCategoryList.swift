//
//  VReminderAllCategoryList.swift
//  RReminders
//
//  Created by Francis Grolemund on 5/13/25.
//

import SwiftUI

struct VReminderAllCategoryList: View {
	@Environment(VMReminderStore.self) private var modelData
	
    var body: some View {
    	List {
			ForEach(modelData.lists) { list in
				VReminderListSection(list, withDivider: list != modelData.lists[0])
			}
		}
		.listStyle(.plain)
		.navigationBarTitleDisplayMode(.large)
		.navigationTitle("All")
    }
}

fileprivate struct VReminderListSection: View {
	let list: VMReminderList
	let hasDivider: Bool
	
	init(_ list: VMReminderList, withDivider: Bool) {
		self.list = list
		self.hasDivider = withDivider
	}
	
	var body: some View {
		Section {
			ForEach(list.reminders) { reminder in
				VReminderListItem(reminder: reminder, pendingReminder: .constant(nil))
			}
			
		} header: {
			VStack(alignment: .leading) {
				if hasDivider {
					Rectangle()
						.frame(height: 2)
						.foregroundStyle(Color.systemGray4)
						.padding(.bottom, 10)
				}
			
				HStack {
					Text(list.name)
						.font(.title2)
						.fontWeight(.bold)
						.foregroundStyle(list.color.uiColor)
						.padding(EdgeInsets(top: 0, leading: 20, bottom: 15, trailing: 20))
					Spacer()
				}
			}
			.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
			.background(Color.white)
		}
		.listSectionSeparator(.hidden)
	}
}

#Preview {
	NavigationStack {
    	VReminderAllCategoryList()
	}
	.environment(_PCReminderModel)
}
