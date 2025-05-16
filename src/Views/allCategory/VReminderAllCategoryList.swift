//
//  VReminderAllCategoryList.swift
//  RReminders
//
//  Created by Francis Grolemund on 5/13/25.
//

import SwiftUI

struct VReminderAllCategoryList: View {
	@Environment(VMReminderStore.self) private var modelData
	@State private var toFocus: VMReminder?
	@State var isEditing: Bool = false
	@State var showCompleted: Bool = false
	
    var body: some View {
    	List {
    		if showCompleted {
    			Section {
					VReminderCompletedHeader(modelData: modelData, count: modelData.numCompleted)
						.listRowSeparator(.hidden)
    			}
    			.listSectionSeparator(.hidden)
    		}
    	
			ForEach(modelData.lists) { list in
				VReminderListSection(list, withDivider: list != modelData.lists[0], showCompleted: $showCompleted, toFocus: $toFocus)
			}
		}
		.listStyle(.plain)
		.navigationBarTitleDisplayMode(.large)
		.navigationTitle("All")
		.toolbar {
			ToolbarItem {
				if !isEditing {
					VAllCategoryInfoMenu(isEditing: $isEditing, showCompleted: $showCompleted)
				}
			}
		}
    }
}

fileprivate struct VReminderCompletedHeader: View {
	let modelData: VMReminderStore
	let count: Int
	
	var body: some View {
		HStack {
			Text("\(count) Completed")
				.foregroundStyle(.secondary)
				
			Text("•")
				.foregroundStyle(.secondary)
				.bold()
	
			Menu {
				Section("Clear Completed Reminders") {
					Button("All Completed") {
						withAnimation {
							modelData.clearCompleted()
						}
					}
				}
			} label: {
				Text("Clear")
					.foregroundStyle(.tint)
			}
			.disabled(count == 0)
		}
	}
}

fileprivate struct VReminderListSection: View {
	let list: VMReminderList
	let hasDivider: Bool
	@Binding private var showCompleted: Bool
	@Binding private var toFocus: VMReminder?
	@State private var pending: VMReminder
	
	init(_ list: VMReminderList, withDivider: Bool, showCompleted: Binding<Bool>, toFocus: Binding<VMReminder?>) {
		self.list = list
		self.hasDivider = withDivider
		self._showCompleted = showCompleted
		self._toFocus = toFocus
		self._pending = .init(initialValue: list.addReminder())
	}
	
	var body: some View {
		Section {
			ForEach(list.reminders(includingCompleted: showCompleted)) { reminder in
				VReminderListItem(reminder: reminder, focusedReminder: $toFocus)
			}
			VReminderListItem(reminder: pending, focusedReminder: $toFocus, allowCompletion: false)
			
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
		.listSectionSpacing(.compact)
	}
}

#Preview("Basic") {
	@Previewable @State var toFocus: VMReminder?
	NavigationStack {
    	VReminderAllCategoryList()
	}
	.environment(_PCReminderModel)
}

#Preview("Completed") {
	@Previewable @State var modelData = _PCReminderModel
	VStack {
		VReminderCompletedHeader(modelData: modelData, count: 5)
		VReminderCompletedHeader(modelData: modelData, count: 0)
	}
}
