//
//  VCategoryBadge.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/8/25.
//

import SwiftUI

struct VCategoryBadge: View {
	let category: ReminderStore.SummaryCategory
	
	init(_ category: ReminderStore.SummaryCategory) {
		self.category = category
	}

	var body: some View {
		Image(systemName: systemIconName)
			.resizable()
			.scaledToFit()
			.foregroundStyle(color)
	}
	
	private var systemIconName: String {
		switch category {
		case .today: return "hourglass.circle.fill"
		case .scheduled: return "calendar.circle.fill"
		case .all: return "tray.circle.fill"
		case .completed: return "checkmark.circle.fill"
		}
	}
	
	private var color: Color {
		switch category {
		case .today: return .blue
		case .scheduled: return .red
		case .all: return .black
		case .completed: return .darkGray
		}
	}
}


#Preview {
	HStack {
		ForEach(ReminderStore.SummaryCategory.allCases) { cat in
			VCategoryBadge(cat)
		}
	}
    
}
