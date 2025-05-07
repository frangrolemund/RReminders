//
//  _VExpNav2.swift
//  RReminders
//
//  Created by Francis Grolemund on 4/23/25.
//

import SwiftUI

fileprivate struct _VExpNav2: View {
	let colors: [Color] = [.purple, .pink, .orange]
	@State private var selection: Color? = nil // Nothing selected by default.
    var body: some View {
		NavigationSplitView {
			 List(colors, id: \.self, selection: $selection) { color in
            	NavigationLink(color.description, value: color)
        	}
			 .listStyle(.plain)
			 .navigationTitle("A split view")
		} detail: {
			if let color = selection {
				Rectangle()
					.foregroundStyle(color)
			} else {
				Text("Pick a color")
			}
		}

    }
}

#Preview {
    _VExpNav2()
}
