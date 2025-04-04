//
//  VDetailsTimeField.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/19/25.
//

import SwiftUI

struct VDetailsTimeField: View {
	@Binding var time: Date?
	@Binding var isExpanded: Bool
	
	@State private var isOn: Bool = false
	@State private var pendingTime: Date = .now

    var body: some View {
		VStack {
			ZStack {
				Button("") {
					isExpanded.toggle()
				}
				.disabled(!isOn)
				
				HStack(spacing: 15) {
					RoundedRectangle(cornerRadius: 6)
						.foregroundStyle(.blue)
						.overlay {
							Image(systemName: "clock")
								.resizable()
								.scaledToFit()
								.foregroundStyle(.white)
								.scaleEffect(0.58)
						}
						.reminderDetailsIconSized()
					
					VStack(alignment: .leading, spacing: 2) {
						Text("Time")
						
						if isOn, let tText = timeText {
							Text("\(tText)")
								.font(.footnote)
								.fixedSize()
								.foregroundStyle(.tint)
						}
					}
					
					Toggle("", isOn: $isOn)
						.onChange(of: isOn) { _, newValue in
							if newValue {
								pendingTime = Date.now
							} else {
								time = nil
							}
						}
				}
			}
			.onChange(of: pendingTime) { _, newValue in
				time = pendingTime
			}

			if isOn && isExpanded {
				Divider()
				
				VTimePicker(time: $pendingTime)
			}
		}
		.onChange(of: time) { oldValue, newValue in
			if let _ = oldValue, newValue == nil {
				isOn = false
				isExpanded = false
			} else if let newValue, oldValue == nil {
				isOn = true
				pendingTime = newValue
			}
		}
    }
}

private extension VDetailsTimeField {
	private var timeText: String? {
		guard let time else { return nil }
		
		return DateFormatter.localizedString(from: time, dateStyle: .none, timeStyle: .short)
	}
}


#Preview {
	@Previewable @State var time: Date? = nil
	@Previewable @State var isExpanded: Bool = true
	List {
		Section {
			VDetailsTimeField(time: $time, isExpanded: $isExpanded)
			Text("More Data...")
		}
	}
}
