//
//  VListInfoPicker.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/12/25.
//

import SwiftUI

struct VListInfoPicker: View {
	@Binding var listColor: ReminderList.Color
	
    var body: some View {
		let topColors: [ReminderList.Color] = [.red, .orange, .yellow, .green, .blue, .purple]
		VStack {
			HStack {
				ForEach(topColors, id: \.self) { color in
					PickerColorItem(itemColor: color, listColor: $listColor)
				}
			}
				
			HStack {
				ForEach(0..<6) { idx in
					PickerColorItem(itemColor: .brown, listColor: $listColor)
						.visible(idx == 0)
				}
			}
		}
		.padding()
		.background(.white)
		.cornerRadius(10)
    }
}


fileprivate struct PickerColorItem: View {
	let itemColor: ReminderList.Color
	@Binding var listColor: ReminderList.Color
		
	var body: some View {
		Circle()
			.foregroundStyle(itemColor.uiColor)
			.aspectRatio(1, contentMode: .fit)
			.scaleEffect(CGSize(width: 0.8, height: 0.8))
			.overlay {
				if itemColor == listColor {
					Circle()
					.stroke(lineWidth: 3)
					.foregroundStyle(.systemGray3)
				} else {
					Color.clear
				}
			}
			.onTapGesture {
				listColor = itemColor
			}
	}
}

#Preview {
	struct PreviewWrapper: View {
		@State var listColor: ReminderList.Color = .blue

        var body: some View {
			VStack {
				VListInfoPicker(listColor: $listColor)
				Spacer()
			}
			.background(.secondarySystemBackground)
        }
    }
    return PreviewWrapper()
}
