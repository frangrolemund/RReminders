//
//  _VExpTextField.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/3/25.
//

import SwiftUI


fileprivate struct _VExpTextField: View {
	@State private var isActive = false
	@State private var text: String = ""

    var body: some View {
        VStack {
			VSearchField(searchText: $text, isEnabled: isActive)
        }
        .toolbar {
            ToolbarItem {
                Button("Toggle") {
                    withAnimation {
                        isActive.toggle()
                    }
                }
            }
        }
    }
}

#Preview {
	NavigationView {
	    _VExpTextField()
			.padding()
	}
}
