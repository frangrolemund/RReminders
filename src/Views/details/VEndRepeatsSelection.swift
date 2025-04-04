//
//  VEndRepeatsSelection.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/23/25.
//

import SwiftUI

struct VEndRepeatsSelection: View {
	@Binding var repeats: Reminder.Repeats?
	@State private var endDate: Date = Date.now
	
	init(repeats: Binding<Reminder.Repeats?>) {
		self._repeats = repeats
	}

    var body: some View {
    	List {
			let isForever = repeats?.ends == nil
			VEndRepeatRow(text: "Repeat Forever", isSelected: isForever)
				.onTapGesture {
                if let curValue = repeats {
                    repeats = .init(id: curValue.id)
                }
            }
			
			VStack {
				VEndRepeatRow(text: "End Repeat Date", isSelected: !isForever)
					.onTapGesture {
						if let curValue = repeats {
	                        if curValue.ends == nil {
								endDate = Date.now
        	                }
            	        }
					}
					
				if !isForever {
					Divider()
					DatePicker("", selection: $endDate, displayedComponents: [.date])
						.datePickerStyle(.graphical)
				}
			}
			.onChange(of: endDate) { _, newValue in
				repeats = .init(id: repeats?.id ?? .daily, ends: newValue)
			}
    	}
		.navigationTitle("End Repeat")
    }
}


#Preview {
	@Previewable @State var repeats: Reminder.Repeats? = .biweekly
	VEndRepeatsSelection(repeats: $repeats)
}


fileprivate struct VEndRepeatRow: View {
	let text: String
	let isSelected: Bool
	
	var body: some View {
		HStack {
			Button("") {}	// - show selection
			
			Text(text)
			
			Spacer()
			
			if isSelected {
				Image(systemName: "checkmark")
					.foregroundStyle(.tint)
					.bold()
			}
		}
		.contentShape(Rectangle())
	}
}

