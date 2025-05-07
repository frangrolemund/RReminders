//
//  VCategoryListItem.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/8/25.
//

import SwiftUI

struct VCategoryListItem: View {
	@Binding var catConfig: ReminderStore.SummaryCategoryConfig
	@State var isToggled: Bool = true
	
    var body: some View {
		HStack(spacing: 12) {
			Button {
				// - omitted in favor of .highPrio below to keep List
				//   from intercepting the touch of this control.
			} label: {
				if catConfig.isVisible {
					Image(systemName: "checkmark.circle.fill")
						.resizable()
				}
				else {
					Circle()
						.stroke(lineWidth: 1)
						.foregroundStyle(.gray)
						.opacity(0.7)
						.padding(EdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1))
				}
			}
			.frame(width: 22, height: 22)
			.buttonStyle(.borderless)
			.highPriorityGesture(TapGesture().onEnded({
				catConfig.isVisible.toggle()
			}))
			
			catConfig.id.icon
				.reminderIconSized()
				
			Text(catConfig.id.description)
		}
		.padding(EdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 0))
    }
}

#Preview {
	@Bindable var modelData = _PCReminderModel
	List {
		ForEach(modelData.summaryCategories.indices, id: \.self) { idx in
			VCategoryListItem(catConfig: $modelData.summaryCategories[idx])
		}
	}
}
