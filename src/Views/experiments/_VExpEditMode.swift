//
//  _VExpEditMode.swift
//  RReminders
//
//  Created by Francis Grolemund on 5/11/25.
//

import SwiftUI

// - I was trying to understand a custom view wasn't detecting .editMode changes
//   and discovered it has something to do with the NavigationStack.
fileprivate struct _VExpEditMode: View {
	@Environment(\.editMode) private var editMode

    var body: some View {
        VStack {
    		EditButton()
    		Text("Edit mode -> \(editMode?.wrappedValue == .active)")
    	}
    }
}

// - this detects the edit mode change
#Preview("ok") {
    _VExpEditMode()
}

// - this doesn't detect the change
#Preview("not-ok") {
	NavigationStack {
    	_VExpEditMode()
	}
}
