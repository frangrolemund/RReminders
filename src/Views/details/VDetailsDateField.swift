//
//  VDetailsDateField.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/16/25.
//

import SwiftUI

struct VDetailsDateField: View {
	@Binding var date: Date?
	@Binding var isExpanded: Bool
	@State private var isOn: Bool = false
	@State private var pendingDate: Date = .now

    var body: some View {
		VStack {
			ZStack {
				Button("") {
					isExpanded.toggle()
				}
				.disabled(!isOn)
				
				HStack(spacing: 15) {
					RoundedRectangle(cornerRadius: 6)
						.foregroundStyle(.red)
						.overlay {
							Image(systemName: "calendar")
								.resizable()
								.scaledToFit()
								.foregroundStyle(.white)
								.scaleEffect(0.58)
						}
						.reminderDetailsIconSized()
					
					VStack(alignment: .leading, spacing: 2) {
						Text("Date")
						
						if isOn, let dText = dateText {
							Text("\(dText)")
								.font(.footnote)
								.fixedSize()
								.foregroundStyle(.tint)
						}
					}
					
					Toggle("", isOn: $isOn)
						.onChange(of: isOn) { _, newValue in
							if newValue {
								pendingDate = Date.now
							} else {
								date = nil
							}
						}
				}
			}
			.onChange(of: pendingDate) { _, newValue in
				date = pendingDate
			}

			if isOn && isExpanded {
				Divider()
				
				DatePicker("", selection: $pendingDate, in: Date.now...Date.distantFuture, displayedComponents: [.date])
					.datePickerStyle(.graphical)
			}
		}
		.onChange(of: date) { oldValue, newValue in
			if let _ = oldValue, newValue == nil {
				isOn = false
			} else if let _ = newValue, oldValue == nil {
				isOn = true
			}
		}
    }
}

private extension VDetailsDateField {
	private var dateText: String? {
		guard let date else { return nil }
		
		let dcNow = Calendar.current.dateComponents(.preciseDay, from: Date.now)
		if dcNow == Calendar.current.dateComponents(.preciseDay, from: date) {
			return "Today"
		}
		
		return DateFormatter.localizedString(from: date, dateStyle: .full, timeStyle: .none)
	}
}


#Preview {
	@Previewable @State var date: Date? = nil
	@Previewable @State var isExpanded: Bool = false
		
	List {
		Section {
			VDetailsDateField(date: $date, isExpanded: $isExpanded)
			Text("Second line")
		}
	}
	.onChange(of: date) { oldValue, newValue in
		// - because the flag is shared, it is best coordinated by
		//   the owner of the field
		if oldValue == nil, newValue != nil {
			isExpanded = true
		}
	}
}
