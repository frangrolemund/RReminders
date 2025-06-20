//
//  VSummaryDisplay.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/7/25.
//

import SwiftUI

struct VSummaryDisplay: View {
	@Binding var isSearching: Bool
	@Binding var navPath: NavigationPath

	@Environment(VMReminderStore.self) var modelData
	@State private var searchText: String = ""
	@Environment(\.editMode) var editMode
	@FocusState private var isSearchFocused: Bool

    var body: some View {
    	@Bindable var modelData = modelData
        
		VStack(spacing: 0) {
			if !isSearching {
				HStack {
					Spacer()
					EditButton()
						.fontWeight(editMode?.wrappedValue == .active ? .semibold : .regular)
				}
				.padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
				.zIndex(20)
			}
		
			List {
				Section {
					HStack {
						VSearchField(searchText: $searchText, isEnabled: !isEditing)
							.textCase(nil)
							.focused($isSearchFocused)
						
						if isSearching {
							VCancelButton {
								isSearchFocused = false
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
						VCategoryCardGroup(categories: modelData.summaryCategories, navPath: $navPath) { cat in
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
							NavigationLink(value: list) {
								VSummaryListItem(list: list, displayStyle: .count)
							}
						}
					}
					.onMove { indices, toOffset in
						modelData.lists.move(fromOffsets: indices, toOffset: toOffset)
					}
					.onDelete { row in
						guard let idx = row.first else { return }
						modelData.lists.remove(at: idx)
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
			.offset(y: -25)
			.listStyle(.insetGrouped)
			.listSectionSpacing(0)
			.onChange(of: isSearchFocused) { _, newValue in
				withAnimation(.easeInOut(duration: 0.2)) {
					isSearching = newValue
				}
			}
		}
		.background(content: {
			Color.secondarySystemBackground
				.ignoresSafeArea()
		})
		.toolbarVisibility(.hidden)
    }
    
	private var isEditing: Bool { editMode?.wrappedValue == .active }
}


#Preview {
	@Previewable @State var isSearching: Bool = false
	@Previewable @State var navPath: NavigationPath = .init()
	VSummaryDisplay(isSearching: $isSearching, navPath: $navPath)
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

