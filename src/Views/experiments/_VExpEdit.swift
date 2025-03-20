//
//  _VExpEdit.swift
//  RReminders
// 
//  Created on 3/2/25
//  Copyright © 2025 Francis Grolemund.  All rights reserved. 
//

import SwiftUI

// - this shows a techique learned from grok that will successfully propagate
//   an edit button in the toolbar through the edit state of a view hiearchy.  The
//   .toolbar modifier apparently creates an isolated environment context which doesn't
//   update the environment of other views automatically.
fileprivate struct _VExpEdit: View {
	@State private var tmpEdit: EditMode = .inactive
	@Environment(\.editMode) private var editMode
    var body: some View {
		NavigationView {
			InnerListView()
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button(tmpEdit == .inactive ? "Edit" : "Done") {
						withAnimation {
							tmpEdit = (tmpEdit == .active) ? .inactive : .active
						}
					}
				}
			}
			.environment(\.editMode, $tmpEdit)
		}
    }
}

fileprivate struct InnerListView: View {
	@Environment(\.editMode) private var editMode
    @State private var items = ["Item 1", "Item 2", "Item 3"]
	var body: some View {
		ZStack(alignment: .topLeading) {
			List {
				ForEach(items, id: \.self) { item in
					Text(item)
				}
				.onDelete { indexSet in
					items.remove(atOffsets: indexSet)
				}
			}
			.navigationTitle("List Test")
			
			if editMode?.wrappedValue == .active {
				Text("EDITING")
			}
		}
	}
}

#Preview {
    _VExpEdit()
}
