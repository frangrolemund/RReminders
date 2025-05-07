//
//  VSearchField.swift
//  RReminders
// 
//  Created on 3/2/25
//  Copyright © 2025 Francis Grolemund.  All rights reserved. 
//

import SwiftUI

struct VSearchField: View {
	@Binding var searchText: String
	private var isEnabled: Bool = false
	
	init(searchText: Binding<String>, isEnabled: Bool = true) {
		self._searchText = searchText
		self.isEnabled = isEnabled
	}

    var body: some View {
		ZStack {
			HStack(spacing: 4) {
				Image(systemName: "magnifyingglass")
				TextField("search", text: $searchText, prompt: Text("Search").foregroundStyle(Color.searchFieldText))
					.textFieldStyle(.plain)
					.foregroundStyle(.black)
				Button {
					// TODO: microphone
				} label: {
					Image(systemName: "microphone.fill")
				}
				.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 2))

			}
			.padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
			.foregroundStyle(Color.searchFieldText)
		}
		.background(Color.searchFieldBackground)
		.clipShape(RoundedRectangle.rect(cornerRadius: 10))
		.disabled(!isEnabled)
		.opacity(isEnabled ? 1.0 : 0.55)
    }
}

#Preview {
	ZStack {
		VStack(alignment: .leading) {
			Spacer()
			Text("Enabled:")
			VSearchField(searchText: .constant(""))
			Text("Disabled:")
			VSearchField(searchText: .constant(""), isEnabled: false)
			Spacer()
		}
		.padding()
	}
	.ignoresSafeArea()
	.ignoresSafeArea()
	.background(Color.secondarySystemBackground)
}
