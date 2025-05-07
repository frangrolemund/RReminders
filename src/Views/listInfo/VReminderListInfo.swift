//
//  VReminderListInfo.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/12/25.
//

import SwiftUI

struct VReminderListInfo: View {
	@Environment(VMReminderStore.self) var model: VMReminderStore
	@Environment(\.dismiss) var dismiss
	
	@State private var list: VMReminderList
	@State private var listColor: ReminderList.Color = .blue
	@State private var listTitle: String = ""
	@State private var isConfirmCancel: Bool = false
	private let listAdded: ReminderListAdded?
	
	typealias ReminderListAdded = (_ list: VMReminderList) -> Void
	init(list: VMReminderList, added: ReminderListAdded? = nil) {
		self._list      = .init(initialValue: list)
		self.listAdded = added
		self._listColor = State(initialValue: list.color)
		self._listTitle = State(initialValue: list.name)
	}
	
    var body: some View {
		NavigationStack {
			VListInfoDisplay(listColor: $listColor, listTitle: $listTitle)
				.navigationBarTitleDisplayMode(.inline)
				.navigationTitle(list.isNew ? "New List" : "List Info")
				.toolbar {
					ToolbarItem(placement: .topBarLeading, content: {
						Button(role: .cancel) {
							if list.isModified {
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
							let isNew = list.isNew
							list.save()
							if isNew, !list.isNew, let listAdded {
								Task {
									listAdded(list)
								}
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
						list.revert()
						dismiss()
					}
				})
				.onChange(of: listTitle, { _, newValue in
					list.name = newValue
				})
				.onChange(of: listColor) { _, newValue in
					list.color = newValue
				}
		}
    }
}

#Preview {
	@Previewable @State var model = _PCReminderModel
    VReminderListInfo(list: model.addReminderList())
		.environment(model)
}
