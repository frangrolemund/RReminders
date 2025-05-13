//
//  VReminderAllCategoryList.swift
//  RReminders
//
//  Created by Francis Grolemund on 5/13/25.
//

import SwiftUI

struct VReminderAllCategoryList: View {
    var body: some View {
    	List {
				Text("All")
					.font(.largeTitle)
					.bold()
					.selectionDisabled()
					.listRowSeparator(.hidden)
					
        		Text("TODO: items")
        		
		}
		.listStyle(.plain)
    }
}

#Preview {
    VReminderAllCategoryList()
}
