//
//  VAllCategoryInfoMenu.swift
//  RReminders
//
//  Created by Francis Grolemund on 5/14/25.
//

import SwiftUI

struct VAllCategoryInfoMenu: View {
	@Binding var isEditing: Bool
	@Binding var showCompleted: Bool
	
    var body: some View {
         Menu {
			Button {
				withAnimation {
					isEditing = true					
				}
			} label: {
				Label("Select Reminders", systemImage: "checkmark.circle")
			}
			
			Button {
				withAnimation {
					showCompleted.toggle()
				}
			} label: {
				if showCompleted {
					Label("Hide Completed", systemImage: "eye.slash")
				} else {
					Label("Show Completed", systemImage: "eye")
				}
			}
			
		} label: {
			Image(systemName: "ellipsis.circle")
				.foregroundStyle(.tint)
		}
    }
}

#Preview {
	@Previewable @State var isEditing: Bool = false
	@Previewable @State var showCompleted: Bool = false
    VAllCategoryInfoMenu(isEditing: $isEditing, showCompleted: $showCompleted)
}
