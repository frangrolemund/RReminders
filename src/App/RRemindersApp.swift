//
//  RRemindersApp.swift
//  RReminders
// 
//  Created on 2/27/25
//  Copyright © 2025 Francis Grolemund.  All rights reserved. 
//

import SwiftUI

@main
struct RRemindersApp: App {
	@State var model = ReminderModel.debugReminderModelDefault
	
    var body: some Scene {
        WindowGroup {
			VReminderSummary()
				.environment(model)
        }
    }
}
