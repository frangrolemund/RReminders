//
//  VReminderAllCategoryList.swift
//  RReminders
//
//  Created by Francis Grolemund on 5/13/25.
//

import SwiftUI

struct VReminderAllCategoryList: View {
	@Environment(\.editMode) private var editMode
	@Environment(VMReminderStore.self) private var modelData
	@State private var toFocus: VMReminder?
	@State var isEditing: Bool = false
	@State var showCompleted: Bool = false
	@State private var selItems: Set<VMReminder>?
	
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
				VReminderListSection(list, withDivider: list != modelData.lists[0], showCompleted: $showCompleted, isEditing: $isEditing, toFocus: $toFocus, groupSelection: $selItems)
			}
		}
		.listStyle(.plain)
		.navigationBarTitleDisplayMode(.large)
		.navigationTitle("All")
		.toolbar {
			ToolbarItem {
				if isEditing {
					VDoneButton {
						isEditing = false
					}
				} else {
					VAllCategoryInfoMenu(isEditing: $isEditing, showCompleted: $showCompleted)
				}
			}
		}
		.onChange(of: isEditing) { _, newValue in
			// - the reactivity of the .editMode doesn't work when views are
			//   in a NavigationStack (see _VExpEditMode), so this technique
			//   modifies it in response to the state changing.
			withAnimation {
				editMode?.wrappedValue = newValue ? .active : .inactive				
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
	@Binding private var isEditing: Bool
	@State private var pending: VMReminder
	@Binding private var selItems: Set<VMReminder>?
	
	init(_ list: VMReminderList, withDivider: Bool, showCompleted: Binding<Bool>, isEditing: Binding<Bool>, toFocus: Binding<VMReminder?>, groupSelection: Binding<Set<VMReminder>?>) {
		self.list = list
		self.hasDivider = withDivider
		self._showCompleted = showCompleted
		self._isEditing = isEditing
		self._toFocus = toFocus
		self._pending = .init(initialValue: list.addReminder())
		self._selItems = groupSelection
	}
	
	var body: some View {
		Section {
			ForEach(list.reminders(includingCompleted: showCompleted)) { reminder in
				VReminderListItem(reminder: reminder, focusedReminder: $toFocus, groupSelection: $selItems)
			}
			.onDelete { isDel in
				print("DELETE")
			}
			.onMove { isMove, toIdx in
				print("MOVE")
			}
			.deleteDisabled(isEditing)
					
			VReminderListItem(reminder: pending, focusedReminder: $toFocus, allowCompletion: false, groupSelection: $selItems)
				.disabled(isEditing)
			
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
