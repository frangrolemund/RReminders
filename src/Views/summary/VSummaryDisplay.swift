//
//  VSummaryDisplay.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/7/25.
//

import SwiftUI

struct VSummaryDisplay: View {
	@Environment(ReminderModel.self) var modelData
	@State private var searchText: String = ""
	@Environment(\.editMode) var editMode
	@FocusState private var isSearching: Bool

    var body: some View {
    	@Bindable var modelData = modelData
        
        List {
			Section {
				HStack {
					VSearchField(searchText: $searchText, isEnabled: !isEditing)
						.textCase(nil)
						.focused($isSearching)
				
					if isSearching {
						Button("Cancel") {
							isSearching = false
						}
					}
				}
				.applyBlendingListRow()
				.padding(EdgeInsets(top: 0, leading: 0, bottom: 25, trailing: 0))
			}

			Section {
				if isEditing {
					ForEach($modelData.summaryCategories) { $cConfig in
						VCategoryListItem(catConfig: $cConfig)
					}
					.onMove { indices, newOffset in
						modelData.summaryCategories.move(fromOffsets: indices, toOffset: newOffset)
					}
				} else if modelData.hasVisibleCategories {
					VCategoryCardGroup(categories: modelData.summaryCategories) { cat in
						return modelData.reminders(for: cat).count
					}
					.background(.secondarySystemBackground)
					.applyBlendingListRow()
				}
			}

			Section {
				ForEach(modelData.lists) { list in
					// - swap out the navigation link because it is implicitly
					//   modified to look disabled during editing.
					if isEditing {
						VSummaryListItem(list: list)
					} else {
						NavigationLink {
							VReminderGenericList(list: list)
						} label: {
							VSummaryListItem(list: list, displayStyle: .count)
						}
					}
				}
				.onMove { indices, toOffset in
					modelData.lists.move(fromOffsets: indices, toOffset: toOffset)
				}
			} header: {
				Text("My Lists")
					.textCase(nil)
					.font(.title2)
					.bold()
					.foregroundStyle(.primary)
					.padding([.bottom], 4)
					.visible(!modelData.lists.isEmpty)
			}
		}
		.listStyle(.insetGrouped)
		.listSectionSpacing(5)
		.toolbarVisibility(isSearching ? .hidden : .visible, for: .navigationBar)
    }
    
	private var isEditing: Bool { editMode?.wrappedValue == .active }
}


#Preview {
    VSummaryDisplay()
		.environment(_PCReminderModel)
}


fileprivate struct BlendingListRowModifier: ViewModifier {
	func body(content: Content) -> some View {
		content
			.listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
			.listRowBackground(Color(uiColor: .secondarySystemBackground))
			.listRowSeparator(.hidden)
	}
}


fileprivate extension View {
	func applyBlendingListRow() -> some View {
		self.modifier(BlendingListRowModifier())
	}
}

