//
//  VRepeatsField.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/19/25.
//

import SwiftUI

struct VRepeatsField: View {
	@Binding var repeats: Reminder.Repeats

    var body: some View {
        HStack(spacing: 15) {
			RoundedRectangle(cornerRadius: 6)
				.foregroundStyle(.systemGray3)
				.overlay {
					Image(systemName: "repeat")
						.resizable()
						.scaledToFit()
						.foregroundStyle(.white)
						.scaleEffect(0.58)
				}
				.reminderDetailsIconSized()

			Text("Repeat")
			
			Spacer()
			
			Text(repeats.longDescription)
				.foregroundStyle(.secondary)
		}
    }
}

#Preview {
	Form {
		Section {
			VRepeatsField(repeats: .constant(.never))
		}
	}
}
