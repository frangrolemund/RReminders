//
//  VCategoryCard.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/7/25.
//

import SwiftUI

struct VCategoryCard: View {
	let category: ReminderStore.SummaryCategory
	let count: Int
	@Binding var navPath: NavigationPath
	
    var body: some View {
		Group {
			VStack(alignment: .leading, spacing: 10) {
				HStack {
					category.icon
						.reminderIconSized()
						
					Spacer()
					Text("\(count)")
						.font(.title)
						.bold()
				}
				
				Text(category.description)
					.font(.headline)
					.fontWeight(.semibold)
					.foregroundStyle(.secondary)
					
			}
			.padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
		}
		.background(Color.white)
		.cornerRadius(10)
		.onTapGesture {
			navPath.append(category)
		}
    }
}


#Preview {
	@Previewable @State var navPath: NavigationPath = .init()
	ZStack {
		Color.secondarySystemBackground
		VStack(spacing: 15) {
			HStack(spacing: 15) {
				VCategoryCard(category: .today, count: 10, navPath: $navPath)
				VCategoryCard(category: .scheduled, count: 3, navPath: $navPath)
			}
			HStack(spacing: 15) {
				VCategoryCard(category: .all, count: 28, navPath: $navPath)
				VCategoryCard(category: .completed, count: 15, navPath: $navPath)
			}
		}
	}
	.ignoresSafeArea()
}
