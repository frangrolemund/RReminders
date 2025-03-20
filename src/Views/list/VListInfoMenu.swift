//
//  VListInfoMenu.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/13/25.
//

import SwiftUI

struct VListInfoMenu: View {
	@Bindable var list: ReminderList
	@State private var isShowingListInfo: Bool = false
	
    var body: some View {
        Menu {
			Button {
				isShowingListInfo = true
			} label: {
				Label("Show List Info", systemImage: "info.circle")
			}
			
			Button {
				print("TODO: select reminders")
			} label: {
				Label("Select Reminders", systemImage: "checkmark.circle")
			}
			
			Button {
				print("TODO: show completed")
			} label: {
				Label("Show Completed", systemImage: "eye")
			}
			
		} label: {
			Image(systemName: "ellipsis.circle")
				.foregroundStyle(.tint)
		}
		.sheet(isPresented: $isShowingListInfo) {
			VReminderListInfo(list: list)
		}
    }
}

#Preview {
	struct PreviewWrapper: View {
		@State private var list: ReminderList = _PCReminderListAlt
		var body: some View {
			NavigationStack {
				Text("Sample Menu")
					.toolbar {
						VListInfoMenu(list: list)
					}
			}
		}
	}
	return PreviewWrapper()
}
