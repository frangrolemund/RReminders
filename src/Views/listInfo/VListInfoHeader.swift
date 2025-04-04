//
//  VListInfoHeader.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/12/25.
//

import SwiftUI

struct VListInfoHeader: View {
	@Binding var listColor: ReminderList.Color
	@Binding var listTitle: String
	
    var body: some View {
		VStack(spacing: 0) {
			InfoBadge(color: listColor)
				.padding()

			VStack {
				let prompt = Text("List Name")
								.font(.title2)
								.fontWeight(.bold)
								
				TextField("text", text: $listTitle, prompt: prompt)
					.multilineTextAlignment(.center)
					.padding()
			}
			.background(.systemGray4)
			.overlay {
				if listTitle != "" {
					HStack {
						Spacer()
						Button {
							listTitle = ""
						} label: {
							Image(systemName: "x.circle.fill")
								.resizable()
								.foregroundStyle(.systemGray2)
						}
						.reminderIconSized(iconDimension: 23)
						.padding()

					}
				}
			}
			.cornerRadius(10)
			.padding([.leading, .trailing, .bottom], 15)
		}
		.frame(maxWidth: .infinity)
		.background(Color.white)
		.cornerRadius(10)
    }
}

fileprivate struct InfoBadge: View {
	let color: ReminderList.Color

	var body: some View {
		ZStack {
			Circle()
				.foregroundStyle(color.uiColor.gradient)
				.shadow(color: color.uiColor.opacity(0.4), radius: 20)
				.opacity(0.9)

			Image(systemName: "list.bullet")
				.resizable()
				.scaledToFit()
				.foregroundStyle(.white)
				.bold()
				.scaleEffect(CGSize(width: 0.50, height: 0.50))
		}
		.frame(width: 90, height: 90)
		
	}
}

#Preview {
	@Previewable @State var listColor: ReminderList.Color = .blue
	@Previewable @State var listTitle: String = ""
	VStack {
			VListInfoHeader(listColor: $listColor, listTitle: $listTitle)
	}
	.frame(maxWidth: .infinity, maxHeight: .infinity)
	.padding()
	.background(.secondarySystemBackground)
}
