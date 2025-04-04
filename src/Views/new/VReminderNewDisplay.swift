//
//  VReminderNewDisplay.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/26/25.
//

import SwiftUI

struct VReminderNewDisplay: View {
	@Binding var reminder: Reminder
	@Binding var list: ReminderList
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
				NavigationLink {
					Text("List")
				} label: {
					Text("List")
				}
    		}
    	}
    }
}

#Preview {
	@Previewable @State var reminder: Reminder = .init(title: "")
	@Previewable @State var list: ReminderList = _PCReminderListDefault
	VReminderNewDisplay(reminder: $reminder, list: $list)
}
