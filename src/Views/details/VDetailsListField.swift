//
//  VDetailsListField.swift
//  RReminders
//
//  Created by Francis Grolemund on 4/7/25.
//

import SwiftUI

struct VDetailsListField: View {
	@Binding var list: VMReminderList
	let isNewItem: Bool
	
	init(list: Binding<VMReminderList>, isNewItem: Bool = false) {
		self._list = list
		self.isNewItem = isNewItem
	}

    var body: some View {
		NavigationLink(destination: {
			VReminderListSelection(list: $list, isNewItem: isNewItem)
		}, label: {
			HStack(spacing: 15) {
				Circle()
					.foregroundStyle(list.color.uiColor)
					.overlay {
						Image(systemName: "list.bullet")
							.resizable()
							.scaledToFit()
							.foregroundStyle(.white)
							.scaleEffect(0.58)
					}
					.reminderDetailsIconSized()
				
				Text("List")
				
				Spacer()

				Text(list.name)
					.foregroundStyle(.secondary)
			}
		})
    }
}

#Preview {
	@Previewable @State var list: VMReminderList = _PCReminderListDefault
	VDetailsListField(list: $list)
		.padding()
}
