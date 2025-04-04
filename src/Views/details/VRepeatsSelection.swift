//
//  VRepeatsSelection.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/19/25.
//

import SwiftUI

struct VRepeatsSelection: View {
	@Binding var repeats: Reminder.Repeats?

    var body: some View {
		List {
			VRepeatsRowItem(text: "Never", isSelected: repeats == nil)
				.onTapGesture {
					repeats = nil
				}
			
			ForEach(Reminder.Repeats.allCases) { rep in
				VRepeatsRowItem(text: rep.description, isSelected: repeats == rep)
					.onTapGesture {
						repeats = rep
					}
			}
    	}
		.navigationTitle("Repeat")
        
    }
}

fileprivate struct VRepeatsRowItem: View {
	let text: String
	let isSelected: Bool

	var body: some View {
		HStack {
			Text(text)
			Spacer()
			if isSelected {
				Image(systemName: "checkmark")
					.foregroundStyle(.tint)
					.bold()
			}
		}
		.contentShape(Rectangle())
	}
}

#Preview {
	@Previewable @State var repeats: Reminder.Repeats?
	VRepeatsSelection(repeats: $repeats)}
