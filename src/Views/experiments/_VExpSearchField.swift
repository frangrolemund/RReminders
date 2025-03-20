//
//  _VExpSearchField.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/4/25.
//

import SwiftUI


fileprivate struct _VExpSearchField: View {
	@State private var text: String = ""
	@FocusState private var isEditing
	@State private var isToolbarVisible = true
	
    var body: some View {
		NavigationStack {
			VStack {
				VSearchField(searchText: $text, isEnabled: true)
					.padding()
					.focused($isEditing)
					.focusable(true)
					
				Spacer()
			}
			.onChange(of: isEditing, { _, newValue in
				isToolbarVisible = !newValue
			})
			.background(content: {
				Rectangle()
					.foregroundStyle(Color.white)
					.onTapGesture {
						withAnimation {
							isToolbarVisible = true
							isEditing = false
						}
					}
			})
			.toolbar(content: {
				ToolbarItem {
					Button("Edit") {
						print("Edit")
					}
				}
			})
			.navigationTitle("")
			.toolbarVisibility(isToolbarVisible ? .visible : .hidden, for: .navigationBar)
		}
    }
}

#Preview {
    _VExpSearchField()
}
