//
//  VDoneButton.swift
//  RReminders
//
//  Created by Francis Grolemund on 5/9/25.
//

import SwiftUI

struct VDoneButton: View {
	let action: @MainActor () -> Void
	
	init(action: @escaping @MainActor () -> Void) {
		self.action = action
	}

    var body: some View {
    	Button("Done") {
    		action()
    	}
    	.fontWeight(.semibold)
    }
}

#Preview {
	VDoneButton {
		print("Clicked done.")
	}
}
