//
//  RRemindersApp.swift
//  RReminders
// 
//  Created on 2/27/25
//  Copyright © 2025 Francis Grolemund.  All rights reserved. 
//

import SwiftUI
import SwiftData

@main
struct RRemindersApp: App {
    var body: some Scene {
        WindowGroup {
			RRemindersWindow()
        }
		.modelContainer(for: ReminderModel.self)
    }
}

// - this is a simplistic data storage approach whereby everything
//   is referenced in a singleton top-level modeled object that is
//   wired-up here and passed through the environment.  The
//   intrinsic behavior of PersistentModel automates the storage.
fileprivate struct RRemindersWindow: View {
	@Environment(\.modelContext) private var context
	@Query private var _model: [ReminderModel]		// - @Query must be a collection
	
	var model: ReminderModel {						// ...but we use it as a singleton
		let ret = _model.first ?? .init()
		if _model.isEmpty {
			context.insert(ret)
		}
		return ret
	}
	
	var body: some View {
		VReminderSummary()
			.environment(model)
	}
}
