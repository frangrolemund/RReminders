//
//  VReminderSummary.swift
//  RReminders
// 
//  Created on 3/1/25
//  Copyright © 2025 Francis Grolemund.  All rights reserved. 
//

import SwiftUI

struct VReminderSummary: View {
	@Environment(VMReminderStore.self) var modelData
	@State private var isSearching: Bool = false
	@State private var isNewListDisplayed: Bool = false
	@State private var isNewReminderDisplayed: Bool = false
	@State private var navPath: NavigationPath = .init()

	var body: some View {
		NavigationStack(path: $navPath) {
			ZStack {
				VSummaryDisplay(isSearching: $isSearching, navPath: $navPath)

				BottomBar(modelData, $isNewListDisplayed, $isNewReminderDisplayed)
					.opacity(isSearching ? 0.0 : 1.0)
					.offset(y: isSearching ? 50 : 0)
			}
			.navigationDestination(for: VMReminderList.self, destination: { list in
				VReminderGenericList(list: list)
			})
			.navigationDestination(for: ReminderStore.SummaryCategory.self, destination: { sc in
				switch sc {
				case .all:
					VReminderAllCategoryList()
				case .scheduled:
					Text("Scheduled")
				case .today:
					Text("Today")
				case .completed:
					Text("Completed")
				}
			})
			.sheet(isPresented: $isNewListDisplayed, content: {
				VReminderListInfo(list: modelData.addReminderList(), added: { (newList) in
					Task {
						try? await Task.sleep(for: .milliseconds(400))
						let _ = newList.addPendingReminder()
						navPath.append(newList)
					}
				})
			})
			.sheet(isPresented: $isNewReminderDisplayed, content: {
				VReminderNew(model: modelData, list: modelData.lists.first!)
			})
		}
    }
}


#Preview("Existing") {
    VReminderSummary()
		.environment(_PCReminderModel)
}

#Preview("New") {
	VReminderSummary()
		.environment(_PCReminderModelNew)
}

fileprivate struct BottomBar: View {
	var modelData: VMReminderStore
	@Binding var isNewListDisplayed: Bool
	@Binding var isNewReminderDisplayed: Bool
	
	init(_ modelData: VMReminderStore,
		 _ isNewListDisplayed: Binding<Bool>,
		 _ isNewReminderDisplayed: Binding<Bool>) {
		self.modelData = modelData
		self._isNewListDisplayed = isNewListDisplayed
		self._isNewReminderDisplayed = isNewReminderDisplayed
	}
	
	var body: some View {
		VStack(alignment: .leading) {
			Spacer()
			HStack {
				Button {
					isNewReminderDisplayed = true
				} label: {
					VNewReminderButtonLabel()
				}
				.disabled(modelData.lists.isEmpty)
						
				Spacer()
						
				Button {
					isNewListDisplayed = true
				} label: {
					Text("Add List")
				}
			}
			.padding()
		}
	}
}

struct VNewReminderButtonLabel: View {
	var body: some View {
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
}
