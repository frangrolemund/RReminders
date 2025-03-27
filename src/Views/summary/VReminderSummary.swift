//
//  VReminderSummary.swift
//  RReminders
// 
//  Created on 3/1/25
//  Copyright © 2025 Francis Grolemund.  All rights reserved. 
//

import SwiftUI

struct VReminderSummary: View {
	@Environment(ReminderModel.self) var modelData
	@State private var localEditMode: EditMode = .inactive
	@State private var isListInfoDisplayed: Bool = false
	@State private var isNewReminderDisplayed: Bool = false

	var body: some View {
		NavigationStack {
			ZStack {
				VSummaryDisplay()
				VStack(alignment: .leading) {
					Spacer()
					HStack {
						Button {
							isNewReminderDisplayed = true
						} label: {
							HStack(spacing: 10) {
								Circle()
									.reminderIconSized(iconDimension: 25)
									.overlay {
										Image(systemName: "plus")
											.foregroundStyle(.white)
									}
								Text("New Reminder")
							}
							.bold()
						}
						.disabled(modelData.lists.isEmpty)
						
						Spacer()
						
						Button {
							isListInfoDisplayed = true
						} label: {
							Text("Add List")
						}
					}
					.padding()
				}
			}
			.toolbar {
				// - EditButton won't propagate state to children through this
				//   environmental context, so this is implemented explicitly.
				ToolbarItem {
					Button(isEditing ? "Done" : "Edit") {
						withAnimation {
							localEditMode = isEditing ? .inactive : .active
						}
					}
					.fontWeight(isEditing ? .bold : .regular)
				}
			}
			.sheet(isPresented: $isListInfoDisplayed, content: {
				VReminderListInfo()
			})
			.sheet(isPresented: $isNewReminderDisplayed, content: {
				VReminderNew(model: modelData)
			})
			.environment(\.editMode, $localEditMode)
		}
    }
    
	private var isEditing: Bool { localEditMode == .active }
}


#Preview("Existing") {
    VReminderSummary()
		.environment(_PCReminderModel)
}

#Preview("New") {
	VReminderSummary()
		.environment(_PCReminderModelNew)
}
