//
//  VReminderNew.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/26/25.
//

import SwiftUI

struct VReminderNew: View {
	var modelData: ReminderModel
	
	init(model: ReminderModel) {
		self.modelData = model
	}
	
    var body: some View {
		Text("New Reminder -> \(modelData.lists.count)")
    }
}

#Preview {
	struct PreviewWrapper: View {
		@State private var modelData: ReminderModel = _PCReminderModel
		
		var body: some View {
			VReminderNew(model: modelData)
		}
	}
	return PreviewWrapper()
}
