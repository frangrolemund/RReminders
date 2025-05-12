//
//  VReminderGenericList.swift
//  RReminders
// 
//  Created on 3/1/25
//  Copyright © 2025 Francis Grolemund.  All rights reserved. 
//

import SwiftUI

struct VReminderGenericList: View {
	@Environment(\.editMode) private var editMode
	@Bindable var list: VMReminderList
	@State private var toFocus: VMReminder?
	@State private var isEditing: Bool = false
	
	init(list: VMReminderList) {
		self.list = list
		let pRem = list.reminders.first(where: {$0.isPending})
		self._toFocus = State(initialValue: pRem)
	}

    var body: some View {
		ZStack {
			List {
				Text(list.name)
					.font(.largeTitle)
					.bold()
					.foregroundStyle(list.color.uiColor)
					.selectionDisabled()
					.listRowSeparator(.hidden)
				
				ForEach(list.reminders) { (reminder: VMReminder) in
					VReminderListItem(reminder: reminder, pendingReminder: $toFocus, titleReturn: { reminder in
						if let idx = list.reminders.firstIndex(of: reminder) {
							toFocus = list.insertReminder(at: idx + 1)
						}
					})
					.tag(reminder.id)
				}
				.onDelete { row in
					guard let idx = row.first else { return }
					list.reminders.remove(at: idx)
				}
			}
			.listStyle(.plain)
			.navigationBarTitleDisplayMode(.inline)
			.onConditionalTapGesture(apply: !(editMode?.wrappedValue.isEditing ?? false)) {
				managePendingReminder()
			}
			
			VStack(alignment: .leading) {
				Spacer()
				HStack {
					Button {
						managePendingReminder()
					} label: {
						VNewReminderButtonLabel()
					}
					.foregroundStyle(list.color.uiColor)
					Spacer()
				}
				.padding()
			}
			.visible(!list.hasPendingReminder)
		}
		.onAppear(perform: {
			isEditing = editMode?.wrappedValue == .active
		})
		.toolbar {
			if isEditing {
				ToolbarItem {
					VDoneButton {
						withAnimation {
							isEditing = false
						}
					}
				}
			} else {
				ToolbarItem {
					VListInfoMenu(list: list, isEditing: $isEditing)
				}
			}
		}
		.onDisappear {
			list.discardPendingReminder()
		}
		.onChange(of: isEditing) { _, newValue in
			// - the reactivity of the .editMode doesn't work when views are
			//   in a NavigationStack (see _VExpEditMode), so this technique
			//   modifies it in response to the state changing.
			editMode?.wrappedValue = newValue ? .active : .inactive
		}
    }
}

#Preview {
	NavigationStack {
		VReminderGenericList(list: _PCReminderListDefault)
	}
}

extension VReminderGenericList {
	private func managePendingReminder() {
		if list.hasPendingReminder {
			list.discardPendingReminder()
		} else {
			toFocus = list.addPendingReminder()			
		}
	}
}
