//
//  VReminderListInfo.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/12/25.
//

import SwiftUI

struct VReminderListInfo: View {
	@Environment(ReminderModel.self) var model: ReminderModel
	@Environment(\.dismiss) var dismiss
	
	@State private var listColor: ReminderList.Color = .blue
	@State private var listTitle: String = ""
	@State private var initialTitle: String = ""
	@State private var isConfirmCancel: Bool = false
	
	var list: ReminderList?
	
	init(list: ReminderList? = nil) {
		self.list = list
		if let list {
			_listColor = State(initialValue: list.color)
			_listTitle = State(initialValue: list.name)
			_initialTitle = State(initialValue: list.name)
		}
	}
	
    var body: some View {
		NavigationStack {
			VListInfoDisplay(listColor: $listColor, listTitle: $listTitle)
				.navigationBarTitleDisplayMode(.inline)
				.navigationTitle(list == nil ? "New List" : "List Info")
				.toolbar {
					ToolbarItem(placement: .topBarLeading, content: {
						Button(role: .cancel) {
							if listTitle != initialTitle {
								isConfirmCancel = true
							} else {
								dismiss()
							}
						} label: {
							Text("Cancel")
						}
						.buttonStyle(.plain)
						.foregroundStyle(.tint)
					})
			
					ToolbarItem {
						Button {
							if let list = list {
								list.name = listTitle
								list.color = listColor
							} else {
								model.lists.append(.init(name: listTitle, color: listColor))
							}
							dismiss()
						} label: {
							Text("Done")
						}
						.buttonStyle(.plain)
						.foregroundStyle(.tint)
						.fontWeight(.semibold)
						.disabled(listTitle == "")
					}
				}
				.confirmationDialog("", isPresented: $isConfirmCancel, titleVisibility: .hidden, actions: {
					Button("Discard Changes", role: .destructive) {
						dismiss()
					}
				})
		}
    }
}

#Preview {
    VReminderListInfo()
		.environment(_PCReminderModel)
}
