//
//  _VExpList7.swift
//  RReminders
//
//  Created by Francis Grolemund on 5/19/25.
//

import SwiftUI

// - this experiment is attempting to find a way to detect taps below the
//   rows while allowing each row to receive taps of its own. (continuation
//   of _VExpList6.
// - it turns out that ScrollView does this naturally without any extra
//   effort.
fileprivate struct _VExpList7: View {
    var body: some View {
        ScrollView {
			VStack(spacing: 0) {
				RowItem("One")
				RowItem("Two")
				RowItem("Three")
				RowItem("Four")
				RowItem("Five")
				RowItem("Six")
				RowItem("Seven")
				RowItem("Eight")
				RowItem("Nine")
			}
		}
		.border(.red)
		.onTapGesture {
			print("TAP SCROLL")
		}
    }
}

#Preview {
    _VExpList7()
}


fileprivate struct RowItem : View {
	let text: String
	
	init(_ text: String) {
		self.text = text
	}
	
	var body: some View {
		HStack(spacing: 0) {
			Text(text)
				.frame(maxHeight: .infinity)
				.border(.orange)
			Spacer()
		}
		.frame(minHeight: 45)
		.contentShape(Rectangle())
		.onTapGesture {
			print("TAP ROW \(text)")
		}
		.border(.green)
		.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
	}
}
