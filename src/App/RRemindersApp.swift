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
		.modelContainer(for: ReminderStore.self)
    }
}

// - this is a simplistic data storage approach whereby everything
//   is referenced in a singleton top-level modeled object that is
//   wired-up here and passed through the environment.  The
//   intrinsic behavior of PersistentModel automates the storage.
fileprivate var hasLogged: Bool = false
fileprivate struct RRemindersWindow: View {
	@Environment(\.modelContext) private var context
	@Query private var _model: [ReminderStore]		// - @Query for ReminderStore must be a collection
	@StateObject private var storeState: StoreState = .init()
	
	// - produce singleton behavior without triggering updates.
	var store: VMReminderStore {
		if let ret = storeState.store { return ret }
		let m = _model.first ?? .init()
		if _model.isEmpty {
			context.insert(m)
		}
		if let u = context.container.configurations.first?.url, !hasLogged {
			hasLogged = true
			print("The RReminders data store is located at \(u.absoluteString).")
		}
		let ret = VMReminderStore(store: m, context: context)
		storeState.store = ret
		return ret
	}
	
	var body: some View {
		VReminderSummary()
			.environment(store)
	}
}

// - save in a @StateObject to preserve the singleton nature
fileprivate class StoreState : ObservableObject {
	var store: VMReminderStore?
}
