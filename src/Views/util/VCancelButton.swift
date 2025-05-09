//
//  VCancelButton.swift
//  RReminders
//
//  Created by Francis Grolemund on 5/9/25.
//

import SwiftUI

struct VCancelButton: View {
	let action: @MainActor () -> Void
	
	init(action: @escaping @MainActor () -> Void) {
		self.action = action
	}

    var body: some View {
    	Button("Cancel") {
    		action()
    	}
    }
}

#Preview {
	VCancelButton {
		print("Clicked cancel.")
	}
}
