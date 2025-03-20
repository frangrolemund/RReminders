//
//  Color+Util.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/19/25.
//

import Foundation
import SwiftUI


extension Color {
	static var random: Color {
		let colors: [Color] = [.black, .blue, .brown, .cyan, .gray, .green, .indigo, .mint, .orange, .pink, .purple, .red, .teal, .yellow]
		return colors.randomElement()!
	}
}
