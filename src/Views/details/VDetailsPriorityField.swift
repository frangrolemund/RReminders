//
//  VDetailsPriorityField.swift
//  RReminders
//
//  Created by Francis Grolemund on 4/8/25.
//

import SwiftUI

struct VDetailsPriorityField: View {
	@Binding var priority: Reminder.Priority?
	@State private var editPrio: PriorityType
	
	init(priority: Binding<Reminder.Priority?>) {
		self._priority = priority
		self.editPrio  = PriorityType.fromReminderPrio(priority.wrappedValue)
	}

    var body: some View {
        HStack(spacing: 15) {
			RoundedRectangle(cornerRadius: 6)
				.foregroundStyle(.red)
				.overlay {
					Text("!")
						.font(.title2)
						.bold()
						.foregroundStyle(.white)
				}
				.reminderDetailsIconSized()

			Picker("Priority", selection: $editPrio) {
				ForEach(PriorityType.allCases) { prio in
					Text(prio.rawValue).tag(prio)
					if (prio == .none) {
						Divider()
					}
				}
			}
		}
		.onChange(of: editPrio) { _, newValue in
			priority = newValue.asReminderPrio
		}
		
    }
}

// - types
extension VDetailsPriorityField {
	private enum PriorityType : String, CaseIterable, Identifiable {
		var id: PriorityType { self }
		
		case none = "None"
		case low = "Low"
		case medium = "Medium"
		case high = "High"
		
		var asReminderPrio: Reminder.Priority? {
			switch self {
			case .none:
				return nil
			case .low:
				return .low
			case .medium:
				return .medium
			case .high:
				return .high
			}
		}
		
		static func fromReminderPrio(_ prio: Reminder.Priority?) -> PriorityType {
			guard let prio else { return .none }
			switch prio {
			case .high: return .high
			case .medium: return .medium
			case .low: return .low
			}
		}
	}
}

#Preview {
	@Previewable @State var priority: Reminder.Priority?
	List {
		VDetailsPriorityField(priority: $priority)
	}
}
