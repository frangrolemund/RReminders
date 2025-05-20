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
	@State private var nbi: VNavigationBarInfo = .init()

	var body: some View {
		GeometryReader { proxy in
			NavigationStack(path: $navPath) {
				VSummaryDisplay(isSearching: $isSearching, navPath: $navPath)
					.navigationDestination(for: VMReminderList.self, destination: { list in
						VReminderGenericListV2(list: list)
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
					.toolbar(content: {
						if !isSearching {
							BottomBar(modelData, $isNewListDisplayed, $isNewReminderDisplayed)	
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
			.onAppear {
				nbi.height = proxy.safeAreaInsets.top
			}
		}
		.environment(nbi)
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

fileprivate struct BottomBar: ToolbarContent {
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
	
	var body: some ToolbarContent {
		ToolbarItemGroup(placement: .bottomBar) {
			VNewReminderButton {
				isNewReminderDisplayed = true
			}
			.disabled(modelData.lists.isEmpty)
		
			Button {
				isNewListDisplayed = true
			} label: {
				Text("Add List")
			}
		}
	}
}



// - used for recreating the nav title merge effect.
@Observable
final class VNavigationBarInfo {
	var height: CGFloat = 0
}
