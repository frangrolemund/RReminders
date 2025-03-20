//
//  _VExpPicker.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/19/25.
//

import SwiftUI

fileprivate struct _VExpPicker: View {
	@State private var selectedHour = (12 * 12) + 6
    @State private var selectedMinute = (7 * 60) + 30
    @State private var selectedPeriod = "AM"
    
    let hours = Array(1...(25 * 12))		// - these dimensions do impact performance
    let minutes = Array(0...(15 * 60))
    let periods = ["AM", "PM"]
    
    var body: some View {
		HStack(spacing: 0) {
            // Hour Wheel
            Picker("Hours", selection: $selectedHour) {
                ForEach(hours, id: \.self) { hour in
                    Text("\((hour % 12) + 1)")
                        .tag(hour)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80) // Adjust width for each wheel
            .clipped() // Prevents overflow
            
            // Minute Wheel
            Picker("Minutes", selection: $selectedMinute) {
                ForEach(minutes, id: \.self) { minute in
                    Text(String(format: "%02d", minute % 60)) // Pads with leading zero
                        .tag(minute)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80)
            .clipped()
            
            // AM/PM Wheel
            Picker("Period", selection: $selectedPeriod) {
                ForEach(periods, id: \.self) { period in
                    Text(period)
                        .tag(period)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80)
            .clipped()
        }
        .padding()
        
        // Display the selected time
        Text("Selected Time: \((selectedHour % 12) + 1):\(String(format: "%02d", selectedMinute % 60)) \(selectedPeriod)")
            .padding(.top)
    }
}

#Preview {
    _VExpPicker()
		.frame(maxWidth: .infinity, maxHeight: .infinity)
}
