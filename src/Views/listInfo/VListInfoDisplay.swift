//
//  VListInfoDisplay.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/12/25.
//

import SwiftUI

struct VListInfoDisplay: View {
	@Binding var listColor: ReminderList.Color
	@Binding var listTitle: String
	@FocusState private var isListFocused: Bool
	
    var body: some View {
		VStack(spacing: 10) {
			VListInfoHeader(listColor: $listColor, listTitle: $listTitle)
				.focused($isListFocused)
			VListInfoPicker(listColor: $listColor)
			Spacer()
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.padding()
		.background(.secondarySystemBackground)
		.onAppear {
			isListFocused = true
		}	
    }
}

#Preview {
	struct PreviewWrapper: View {
		@State private var listColor: ReminderList.Color = .blue
		@State private var listTitle: String = ""
		var body: some View {
			VListInfoDisplay(listColor: $listColor, listTitle: $listTitle)
		}
	}
	return PreviewWrapper()
}
