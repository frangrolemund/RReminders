//
//  _VExpSafeArea.swift
//  RReminders
//
//  Created by Francis Grolemund on 4/23/25.
//

import SwiftUI

fileprivate struct _VExpSafeArea: View {
    var body: some View {
		ZStack {
			Color.secondarySystemBackground
				.ignoresSafeArea()
				
			VStack {
				HStack {
					Spacer()
					EditButton()
				}
				.padding()
				
				List {
					Text("ABC")
					Text("DEF")
				}
			}
		}
    }
}

#Preview {
    _VExpSafeArea()
}
