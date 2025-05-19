//
//  _VexpList6.swift
//  RReminders
//
//  Created by Francis Grolemund on 5/19/25.
//

import SwiftUI

// - this experiment is attempting to find a way to detect taps below the
//   rows while allowing each row to receive taps of its own.  This is
//   mostly possible if the row is explicitly sized and no automatic
//   insets, spacing or padding are used from the default list.
// - even with the solution provided here, small things can impact whether
//   taps are interpreted correctly or very clear taps on a row are just
//   not received there and passed onto the list.  It is only partially
//   reliable at best and completely unreliable at worst.

fileprivate struct _VexpList6: View {
    var body: some View {
		VStack {
			List {
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
			.listStyle(.plain)
			.listRowSpacing(0)		// - appears to be important
			.border(.red)
			.onTapGesture {
				print("TAP LIST 2")
			}
		}
    }
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
		.contentShape(Rectangle())
		.onTapGesture {
			print("TAP ROW \(text)")
		}
		.border(.green)
		.background(GeometryReader { geo in
            Color.clear
                .preference(key: HeightPreferenceKey.self, value: [geo.size.height])
        })
		.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
	}
}

#Preview {
    _VexpList6()
}

fileprivate struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: [CGFloat] = []
    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value.append(contentsOf: nextValue())
    }
}
