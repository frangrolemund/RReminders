//
//  VReminderGenericListV2.swift
//  RReminders
//
//  Created by Francis Grolemund on 5/19/25.
//

import SwiftUI

// - an alternate implementation using ScrollView instead of List so that
//   taps are more predictable below the list.
struct VReminderGenericListV2: View {
	@Environment(\.editMode) private var editMode
	@Environment(VNavigationBarInfo.self) var navBarInfo
	@Bindable var list: VMReminderList
	@State private var toFocus: VMReminder?
	@State private var isEditing: Bool = false
	@State private var isTitleInline: Bool = false
	@State private var selItems: Set<VMReminder>?
	
	init(list: VMReminderList) {
		self.list = list
		let pRem = list.reminders.first(where: {$0.isPending})
		self._toFocus = State(initialValue: pRem)
	}

    var body: some View {
		ZStack {
			ScrollView {
				LazyVStack(alignment: .leading, spacing: 0) {
					Text(self.reminderListTitle)
						.font(.largeTitle)
						.bold()
						.foregroundStyle(list.color.uiColor)
						.background(content: {
							// - if this isn't in the background, SwiftUI renders a
							//   separator between the toolbar and the content
							Color.clear
								.onGeometryChange(for: Bool.self) { proxy in
									// ...simulates the traditional list behavior where it will
									//   merge into the nav bar when scrolling upwards, while
									//   retaining the ability to change its styling
									let f = proxy.frame(in: .scrollView)
									return f.minY < -navBarInfo.height
								} action: { newValue in
									withAnimation {
										isTitleInline = newValue
									}
								}
						})
						.visible(!isTitleInline)
						.padding([.leading], 20)
						.padding([.bottom], 5)
										
					ForEach(list.reminders) { (reminder: VMReminder) in
						VStack(spacing: 0) {
							VReminderListItem(reminder: reminder, focusedReminder: $toFocus, groupSelection: $selItems, titleReturn: { reminder in
								if let idx = list.reminders.firstIndex(of: reminder) {
									toFocus = list.insertReminder(at: idx + 1)
								}
							})
							.tag(reminder.id)
							.padding(EdgeInsets(top: 7, leading: 20, bottom: 7, trailing: 20))
							
							Rectangle()
								.frame(maxWidth: .infinity, idealHeight: 1)
								.offset(x: 50)
								.foregroundStyle(Color.gray.opacity(0.3))
						}
						.contentShape(Rectangle())
						.onTapGesture{} // - prevents taps from going thru
					}
					.onDelete { isDel in
						guard let idx = isDel.first else { return }
						list.reminders.remove(at: idx)
					}
					.onMove(perform: { isMove, toIdx in
						print("MOVE")
					})
					.deleteDisabled(isEditing)
				}
				.navigationBarTitleDisplayMode(.inline)
				.navigationTitle(isTitleInline ? self.reminderListTitle : "")
			}
			.onTapGesture(perform: {
				guard !(editMode?.wrappedValue.isEditing ?? false) else { return }
				managePendingReminder()
			})
			.toolbar {
				if !list.hasPendingReminder {
					ToolbarItemGroup(placement: .bottomBar) {
						HStack {
							Button {
								managePendingReminder()
							} label: {
								VNewReminderButtonLabel()
							}
							.foregroundStyle(list.color.uiColor)
							
							Spacer()
						}
					}
				}
			}
		}
		.onAppear(perform: {
			isEditing = editMode?.wrappedValue == .active
			selItems = isEditing ? .init() : nil
		})
		.toolbar {
			ToolbarItem {
				if isEditing {
					VDoneButton {
						isEditing = false
					}
				} else {
					VListInfoMenu(list: list, isEditing: $isEditing)
				}
			}
		}
		.onDisappear {
			list.discardPendingReminder()
		}
		.onChange(of: isEditing) { _, newValue in
			// - the reactivity of the .editMode doesn't work when views are
			//   in a NavigationStack (see _VExpEditMode), so this technique
			//   modifies it in response to the state changing.
			withAnimation {
				selItems = newValue ? .init() : nil
				editMode?.wrappedValue = newValue ? .active : .inactive
			}
		}
    }
    
    private var reminderListTitle: String {
    	if isEditing {
    		if let ct = selItems?.count, ct > 0 {
    			return "\(ct) Selected"
    		} else {
    			return "Select Reminders"
    		}
    		
    	} else {
    		return list.name
    	}
    }
}

#Preview {
	NavigationStack {
		VReminderGenericListV2(list: _PCReminderListDefault)
			.environment(VNavigationBarInfo())
	}
}

extension VReminderGenericListV2 {
	private func managePendingReminder() {
		if list.hasPendingReminder {
			list.discardPendingReminder()
		} else {
			toFocus = list.addPendingReminder()			
		}
	}
}
