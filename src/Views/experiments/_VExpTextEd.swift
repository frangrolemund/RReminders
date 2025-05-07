//
//  _VExpTextEd.swift
//  RReminders
//
//  Created by Francis Grolemund on 4/7/25.
//

import SwiftUI

fileprivate struct _VExpTextEd: View {
	@State private var text: String = ""
	@State private var text2: String = ""
	@FocusState private var isFocused: Bool
	
    var body: some View {
		VStack(alignment: .leading) {
			Spacer()
			Text("Edit Text Below")
			TextEditor(text: $text)
				.focused($isFocused)
				.border(.green)
				.frame(height: 200)
			TextField("Sample", text: $text2)
			Spacer()
		}
		.onChange(of: isFocused) { oldValue, newValue in
			print("FOCUS CHANGE -> \(newValue ? "ON" : "OFF")")
		}
    }
}

#Preview {
    _VExpTextEd()
}
