//
//  VCategoryCardGroup.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/7/25.
//

import SwiftUI

struct VCategoryCardGroup: View {
	let categories: [ReminderModel.SummaryCategoryConfig]
	let countedWith: (_ cat: ReminderModel.SummaryCategory) -> Int
	
    var body: some View {
		let vCat = visibleCategories
		if !vCat.isEmpty {
			VStack(spacing: 15) {
				HStack(spacing: 15) {
					VCategoryCard(category: vCat[0].id, count: countedWith(vCat[0].id))
					
					let hasSecond = vCat.count > 1
					let cCat      = vCat[hasSecond ? 1 : 0].id
					VCategoryCard(category: cCat, count: countedWith(cCat))
						.visible(hasSecond)
				}
				
				if vCat.count > 2 {
					HStack(spacing: 15) {
						VCategoryCard(category: vCat[2].id, count: countedWith(vCat[2].id))
						
						let hasFourth = vCat.count > 3
						let cCat      = vCat[hasFourth ? 3 : 2].id
						VCategoryCard(category: cCat, count: countedWith(cCat))
							.visible(hasFourth)
					}
				}
			}
		}
    }
    
	private var visibleCategories: [ReminderModel.SummaryCategoryConfig] {
		return categories.filter({$0.isVisible})
	}
}

#Preview {
	ZStack {
		Color.secondarySystemBackground
		VStack(spacing: 50) {
			VCategoryCardGroup(categories: _PCReminderModel.summaryCategories) { cat in
				switch cat {
				case .all: return 55
				case .scheduled: return 3
				case .today: return 10
				case .completed: return 42
				}
			}
			
			VCategoryCardGroup(categories: [.all, .completed, .today]) { cat in
				switch cat {
				case .all: return 13
				case .scheduled: return 4
				case .today: return 7
				case .completed: return 6
				}
			}
			
			VCategoryCardGroup(categories: [.scheduled]) { cat in
				switch cat {
				case .all: return 13
				case .scheduled: return 17
				case .today: return 7
				case .completed: return 6
				}
			}
		}
		.padding()
	}
	.ignoresSafeArea()
}
