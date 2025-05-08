//
//  VListInfoMenu.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/13/25.
//

import SwiftUI

struct VListInfoMenu: View {
	@Bindable var list: VMReminderList
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
				withAnimation {
					list.showCompleted.toggle()
				}
			} label: {
				if list.showCompleted {
					Label("Hide Completed", systemImage: "eye.slash")
				} else {
					Label("Show Completed", systemImage: "eye")
				}
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
	@Previewable @State var list: VMReminderList = _PCReminderListAlt
	VListInfoMenu(list: list)
}
