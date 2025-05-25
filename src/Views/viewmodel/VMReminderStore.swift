//
//  VMReminderStore.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/11/25.
//

import Foundation
import SwiftData

@Observable
final class VMReminderStore {
	// - pass a nil context to use an in-memory db.
	init(store: ReminderStore, context: ModelContext? = nil) {
		self.model = store
		if let ctx = context {
			self.context = ctx
		} else {
			let mc = try! ModelContainer(for: ReminderStore.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
			self.context = ModelContext(mc)
		}
	}
	
	private var model: ReminderStore
	private var context: ModelContext
	private var _lists: [VMReminderList]?
}

// - types/accessors
extension VMReminderStore {
	enum VMError : Error, LocalizedError {
		case orphaned
		
		var errorDescription: String? {
			switch self {
			case .orphaned:
				return "The instance connection to the store does not exist."
			}
		}
	}
	
	var lists: [VMReminderList] {
		get {
			if let ret = _lists { return ret }
			let ret = model.lists.map({VMReminderList(store: InternalProxy(store: self), list: $0)})
			_lists = ret
			return ret
		}
	
		set {
			// - this operation is necessary to allow reordering, but it needs to be done
			//   carefully to ensure the backing data is consistent.
			newValue.forEach({$0.save()})
			model.lists = model.lists.filter { ml in
				newValue.firstIndex { nv in
					ml.id == nv.id
				} != nil
			}
			_lists = newValue
			self.save()
		}
	}
	
	var summaryCategories: [ReminderStore.SummaryCategoryConfig] {
		get { model.summaryCategories }
		set {
			guard Set(newValue.map({$0.id})).count == model.summaryCategories.count else { return }
			model.summaryCategories = newValue
			self.save()
		}
	}
	
	var numCompleted: Int {
		return lists.reduce(0) { partialResult, list in
			partialResult + list.numCompleted
		}
	}
		
	var hasVisibleCategories: Bool { summaryCategories.firstIndex(where: {$0.isVisible}) != nil }
	
	func reminders(for category: ReminderStore.SummaryCategory) -> [VMReminder] {
		return lists.reduce(into: [VMReminder]()) { (partialResult, next) in
			let listRem = next.reminders
			switch category {
			case .all:
				partialResult += Array(listRem)
				
			case .completed:
				partialResult += listRem.filter({$0.isCompleted})
				
			case .scheduled:
				partialResult += listRem.filter({$0.notifyOn != nil})
				
			case .today:
				partialResult += listRem.filter({$0.isCompleted == false})
			}
		}
	}
	
	// - new lists must invoke save() to be persisted in the store
	func addReminderList(name: String = "", color: ReminderList.Color = .blue) -> VMReminderList {
		VMReminderList(store: InternalProxy(store: self), name: name, color: color)
	}
	
	@discardableResult func save() -> Result<Bool, Error> {
		do {
			try context.save()
			return .success(true)
			
		} catch {
			print("ERROR: Failed to save reminder store.  \(error.localizedDescription)")
			return .failure(error)
		}
	}
	
	func clearCompleted() {
		self.lists.forEach { list in
			list.clearCompleted()
		}
		self.save()
	}
}

protocol VMReminderStoreInternal : AnyObject {
	var vmStore: VMReminderStore? { get }
	func isNew(list: ReminderList) -> Bool
	func save(list: ReminderList, from: VMReminderList) -> Result<Bool, Error>
}

private extension VMReminderStore {
	// - the interface from the dependent list back into the store guards against
	//   retain cycles and can access private attributes as needed.
	class InternalProxy : VMReminderStoreInternal {
		private(set) weak var vmStore: VMReminderStore?
		
		init(store: VMReminderStore) {
			self.vmStore = store
		}
		
		func isNew(list: ReminderList) -> Bool {
			return vmStore?.model.lists.firstIndex(where: {$0.id == list.id}) == nil
		}
	
		func save(list: ReminderList, from: VMReminderList) -> Result<Bool, Error> {
			guard let vmStore else { return .failure(VMError.orphaned) }
			if vmStore.lists.firstIndex(of: from) == nil {
				var tmp = vmStore.lists
				tmp.append(from)
				vmStore.model.lists.append(list)
				vmStore._lists = tmp
			}
			return vmStore.save()
		}
	}
}
