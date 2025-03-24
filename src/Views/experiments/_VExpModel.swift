//
//  _VExpModel.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/24/25.
//

import SwiftUI
import SwiftData

// - proves that @Model conveys observability as described on this page:
// https://developer.apple.com/documentation/swiftdata/preserving-your-apps-model-data-across-launches
@Model
fileprivate class Trip {
    var name: String
    init(name: String) {
        self.name = name
    }
}

fileprivate struct _VExpModel: View {
    @State private var trip = Trip(name: "Initial")
    var body: some View {
        VStack {
            Text(trip.name)
            Button("Change Name") {
                trip.name = "Updated" // Should trigger view update if Observable
            }
        }
    }
}

#Preview {
    _VExpModel()
}
