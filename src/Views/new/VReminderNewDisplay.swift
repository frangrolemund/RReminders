//
//  VReminderNewDisplay.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/26/25.
//

import SwiftUI

struct VReminderNewDisplay: View {
	@Binding var reminder: VMReminder
	@State private var notes: String = ""
	@FocusState private var isNotesFocused: Bool
	@Binding private var list: VMReminderList
	private var addAction: AddAction?
	
	typealias AddAction = () -> Void
	
	init(reminder: Binding<VMReminder>, list: Binding<VMReminderList>, addAction: AddAction? = nil) {
		self._reminder = reminder
		self._list = list
		self.addAction = addAction
	}
	
    var body: some View {
    	List {
    		Section {
				TextField("Title", text: $reminder.title)
				TextEditor(text: $notes)
					.focused($isNotesFocused)
					.frame(minHeight: 75, maxHeight: 175)
					.offset(x: -2)
					.overlay {
						VStack(alignment: .leading) {
							Text("Notes")
								.frame(maxWidth: .infinity, alignment: .leading)
								.foregroundStyle(.tertiary)
								.padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
								.visible(!isNotesFocused && notes.isEmpty)
							Spacer()
						}
					}
					.onChange(of: notes) { _, newValue in
						reminder.notes = newValue.isEmpty ? nil : newValue
					}
    		}
    		
    		Section {
				NavigationLink {
					VDetailsDisplay(reminder: reminder, style: .new)
						.navigationTitle("Details")
						.toolbar {
							ToolbarItem {
								Button(action: {
									self.addAction?()
								}) {
									Text("Add")
										.bold()
								}
								.disabled(!reminder.allowCreation)
							}
						}
				} label: {
					Text("Details")
				}
    		}
    		
    		Section {
				VDetailsListField(list: $list, isNewItem: true)
    		}
    	}
    }
}

#Preview {
	@Previewable @State var reminder: VMReminder = _PCReminderListDefault.addReminder()
	VReminderNewDisplay(reminder: $reminder, list: $reminder.list)
}
