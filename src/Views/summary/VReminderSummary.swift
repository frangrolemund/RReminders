//
//  VReminderSummary.swift
//  RReminders
// 
//  Created on 3/1/25
//  Copyright © 2025 Francis Grolemund.  All rights reserved. 
//

import SwiftUI

struct VReminderSummary: View {
	@State private var localEditMode: EditMode = .inactive
	@State private var isListInfoDisplayed: Bool = false

	var body: some View {
		NavigationStack {
			ZStack {
				VSummaryDisplay()
				VStack(alignment: .leading) {
					Spacer()
					HStack {
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
			.environment(\.editMode, $localEditMode)
		}
    }
    
	private var isEditing: Bool { localEditMode == .active }
}


#Preview {
    VReminderSummary()
		.environment(_PCReminderModel)
}
