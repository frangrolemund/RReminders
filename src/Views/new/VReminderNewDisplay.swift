//
//  VReminderNewDisplay.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/26/25.
//

import SwiftUI

struct VReminderNewDisplay: View {
	@Binding var reminder: Reminder
	@State private var notes: String = ""
	
    var body: some View {
    	List {
    		Section {
				TextField("Title", text: $reminder.title)
				TextField("Notes", text: $notes)
    		}
    		
    		Section {
				NavigationLink {
					Text("Destination")
				} label: {
					Text("Details")
				}
    		}
    		
    		Section {
				VDetailsListField(reminder: $reminder, isNewItem: true)
    		}
    	}
    }
}

#Preview {
	@Previewable @State var reminder: Reminder = .init(list: _PCReminderListDefault, title: "")
	VReminderNewDisplay(reminder: $reminder)
}
