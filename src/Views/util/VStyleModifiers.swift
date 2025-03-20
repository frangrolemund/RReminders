//
//  VStyleModifiers.swift
//  RReminders
// 
//  Created on 2/27/25
//  Copyright © 2025 Francis Grolemund.  All rights reserved. 
//

import SwiftUI

/// Changes the visibility of a view based on a boolean value
struct VVisibleModifier: ViewModifier {
	let isVisible: Bool
	
	init(isVisible: Bool = true) {
		self.isVisible = isVisible
	}
	
	func body(content: Content) -> some View {
		if isVisible {
			content
		} else {
			content.hidden()
		}
	}
}

struct VIconSizeModifier: ViewModifier {
	let iconDimension: CGFloat
	
	func body(content: Content) -> some View {
		content
			.frame(width: iconDimension, height: iconDimension)
	}
}

extension View {
	func visible(_ isVisible: Bool = true) -> some View {
		self.modifier(VVisibleModifier(isVisible: isVisible))
	}
	
	func reminderIconSized(iconDimension: CGFloat = 32) -> some View {
		self.modifier(VIconSizeModifier(iconDimension: iconDimension))
	}
	
	func reminderDetailsIconSized() -> some View {
		self.reminderIconSized(iconDimension: 27)
	}
}
