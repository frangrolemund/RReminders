//
//  _VExpList5.swift
//  RReminders
//
//  Created by Francis Grolemund on 5/11/25.
//

import SwiftUI

// - to understand the deletion behavior a bit better.
fileprivate struct _VExpList5: View {
	@Environment(\.editMode) var editMode
	@State private var items = ["Apple", "Pear", "Grapes", "Banana", "Kiwi", "Strawberries"]
    var body: some View {
    	VStack {
    		HStack {
    			Spacer()
    			
    			Button("Reload") {
    				self.items = ["Dogs", "Cats", "Koalas", "Giraffes", "Snakes"]
    			}
    			
    			Button("Edit") {
					withAnimation {
    					self.editMode?.wrappedValue = self.editMode?.wrappedValue == .inactive ? .active : .inactive
					}
    			}
    		}
			List {
				ForEach(items, id: \.self) { item in
					ListItem(text: item)
				}
				.onDelete { iSet in
					guard let idx = iSet.first else { return }
					items.remove(at: idx)
				}
			}
    	}
    	.padding()
    }
}

fileprivate struct ListItem : View {
	@Environment(\.editMode) var editMode
	let text: String
	@State private var toEdit: String = ""
	
	var body: some View {
		VStack(alignment: .leading) {
			TextField("custom text", text: $toEdit)
				.disabled(editMode?.wrappedValue == .active)
			Text("l-item -> \(text)")
		}
	}
}

#Preview {
    _VExpList5()
}
