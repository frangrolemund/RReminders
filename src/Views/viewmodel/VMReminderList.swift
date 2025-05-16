//
//  VMReminderList.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/11/25.
//

import Foundation

@Observable
class VMReminderList: Identifiable, Hashable, AnyObject {
	static func == (lhs: VMReminderList, rhs: VMReminderList) -> Bool { lhs.id == rhs.id }
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
	
	var id: UUID { model.id }
	
	var name: String {
		get { _pendingName ?? model.name }
		set { _pendingName = newValue }
	}
	
	var color: ReminderList.Color {
		get { _pendingColor ?? model.color }
		set { _pendingColor = newValue }
	}
	
	var showCompleted: Bool {
		get { model.showCompleted }
		set {
			model.showCompleted = newValue
			self.save()
			_sortedReminders = nil
		}
	}
	
	var sortOrder: ReminderList.SortOrder {
		get { model.sortOrder }
		set {
			model.sortOrder = newValue
			_sortedReminders = nil
			self.save()
		}
	}
	
	init(store: VMReminderStoreInternal,
		id: UUID = .init(),
		name: String,
		color: ReminderList.Color = .blue,
		showCompleted: Bool = false,
		sortOrder: ReminderList.SortOrder = .manual) {
		self.store = store
		self.model = ReminderList(id: id, name: name, color: color, reminders: [], showCompleted: showCompleted, sortOrder: sortOrder)
	}
	
	// - only stores create these
	init(store: VMReminderStoreInternal, list: ReminderList) {
		self.store = store
		self.model = list
	}
			
	subscript(index: Int) -> VMReminder {
		get { sortedReminders[index] }
		set {
			let rid = sortedReminders[index].id
			if let mIdx = reminders.firstIndex(where: { r in r.id == rid }) {
				reminders[mIdx] = newValue
			}
		}
	}
	
	private let store: any VMReminderStoreInternal
	private let model: ReminderList
	private var _pendingName: String?
	private var _pendingColor: ReminderList.Color?
	
	// ...two caches of VMReminder are necessary: (a) one to save all of the committed instances and (b) one for the arbitrary sort order that can be changed
	private var _rawReminders: Set<VMReminder>?
	private var _sortedReminders: [VMReminder]?
}


// - types/accessors
extension VMReminderList {		
	var startIndex: Int { reminders.startIndex }
	var endIndex: Int { reminders.endIndex }
	var count: Int { reminders.count }
	var numCompleted: Int {
		return model.reminders.reduce(0) { partialResult, rem in
			return partialResult + (rem.completedOn != nil ? 1 : 0)
		}
	}
	
	var reminders: [VMReminder] {
		get { sortedReminders }
		
		set {
			// - this operation is necessary to allow reordering, but it needs to be done
			//   carefully to ensure the backing data is consistent.
			newValue.forEach({$0.save()})
			syncModelItemsAndSortOrder(withSorted: newValue)
			_sortedReminders = nil
			self.save()
		}
	}
	
	var hasPendingReminder: Bool {
		guard let sr = _sortedReminders, let rr = _rawReminders else { return false }
		return sr.count == rr.count + 1
	}
	
	var isNew: Bool { store.isNew(list: model) }
	
	// - modification is only tracked for elements that require an explicit save()
	var isModified: Bool {
		guard (_pendingName != nil && _pendingName != model.name) ||
			  (_pendingColor != nil && _pendingColor != model.color) else { return false }
		
		return true
	}
	
	@discardableResult func save() -> Result<Bool, Error> {
		model.name = _pendingName ?? model.name
		_pendingName = nil
		model.color = _pendingColor ?? model.color
		_pendingColor = nil
		return store.save(list: model, from: self)
	}
	
	func revert() {
		_pendingName = nil
		_pendingColor = nil
	}

	private var sortedReminders: [VMReminder] {
		if let ret = _sortedReminders { return ret }
		
		let unsorted: [VMReminder]
		if let tmp = _rawReminders {
			unsorted = Array(tmp)
			
		} else {
			unsorted = model.reminders.map({VMReminder(list: InternalProxy(list: self), reminder: $0)})
			_rawReminders = Set(unsorted)
			
		}
		
		let resorted: [VMReminder]
		switch sortOrder {
		case .manual:
			resorted = unsorted.sorted(by: { r1, r2 in
				(!r1.isCompleted || r2.isCompleted) && r1.listOrder < r2.listOrder
			})
		
		case .dueDate:
			resorted = unsorted.sorted(by: { r1, r2 in
				(!r1.isCompleted || r2.isCompleted) && r1.dueDate < r2.dueDate
			})
			
		case .creationDate:
			resorted = unsorted.sorted(by: { r1, r2 in
				(!r1.isCompleted || r2.isCompleted) && r1.created < r2.created
			})
			
		case .priority:
			resorted = unsorted.sorted(by: { r1, r2 in
				(!r1.isCompleted || r2.isCompleted) && (r1.priority?.rawValue ?? 99) < (r2.priority?.rawValue ?? 99)
			})
			
		case .title:
			resorted = unsorted.sorted(by: { r1, r2 in
				(!r1.isCompleted || r2.isCompleted) && r1.title.localizedCompare(r2.title) == .orderedAscending
			})
		}
		
		let filtered = resorted.filter( {showCompleted || !$0.isCompleted} )
		_sortedReminders = filtered
		return filtered
	}
			
	// - modifies _rawReminders
	private func syncModelItemsAndSortOrder(withSorted list: [VMReminder]) {
		// - the objectives are to (a) handle deletions correctly, (b) reorder
		//   records to match the inbound list and (c) ensure that the authoritative
		//   cache of viewmodel reminders is consistent with the model.  Because the
		//   list will possibly omit records that were completed, that state must be
		//   considered when deciding on deletion.
		var newModeled = model.reminders.filter({ rem in
			if let _ = rem.completedOn, !self.showCompleted {
				return true
			}
			
			if let _ = list.firstIndex(where: { vrem in
				vrem.id == rem.id
			}) {
				return true
			}
			
			return false
		})
		
		newModeled = newModeled.sorted(by: { r1, r2 in
			let o1 = list.firstIndex(where: {$0.id == r1.id} ) ?? newModeled.count
			let o2 = list.firstIndex(where: {$0.id == r2.id} ) ?? newModeled.count
			return o1 < o2
		})
		
		model.reminders = newModeled

		// - only filter _rawReminders based on the model because that is how it
		//   was originally built, they must remain in sync.
		self._rawReminders = Set(list).union(self._rawReminders?.filter({ vrem in
			newModeled.firstIndex { $0.id == vrem.id } != nil
		}) ?? .init())
	}
	
	// - not tracked in the sorted list and can be quietly discarded
	func addReminder(title: String = "", notes: String? = nil, notifyOn: Reminder.RemindOn? = nil, priority: Reminder.Priority? = nil, completedOn: Date? = nil) -> VMReminder {
		VMReminder(list: InternalProxy(list: self), title: title, notes: notes, notifyOn: notifyOn, priority: priority, completedOn: completedOn)
	}
	
	// - the sorted list is a temporary scratchpad to manage position
	func insertReminder(at pos: Int, title: String = "", notes: String? = nil, notifyOn: Reminder.RemindOn? = nil, priority: Reminder.Priority? = nil, completedOn: Date? = nil) -> VMReminder {
		assert((_rawReminders?.count ?? 0) == (_sortedReminders?.count ?? 0))	// - only one at a time
		let count = self.reminders.count
		assert(pos >= 0 && pos <= count)
		let i = min(pos, count)
		let rem = VMReminder(list: InternalProxy(list: self), title: title, notes: notes, notifyOn: notifyOn, priority: priority, completedOn: completedOn)
		_sortedReminders?.insert(rem, at: i)
		return rem
	}
	
	func addPendingReminder() -> VMReminder? {
		guard !hasPendingReminder else { return nil }
		return insertReminder(at: self.reminders.count)
	}
	
	func discardPendingReminder() {
		guard hasPendingReminder else { return }
		self._sortedReminders = self._sortedReminders?.filter({ rem in
			self._rawReminders?.contains(rem) ?? false
		})
	}
	
	func clearCompleted() {
		self.reminders = self.reminders.filter({ !$0.isCompleted })
	}
}

protocol VMReminderListInternal : AnyObject, Identifiable {
	var id: UUID { get }
	var vmList: VMReminderList? { get }
	func asVMInternal(_ other: VMReminderList) -> any VMReminderListInternal
	func save(reminder: Reminder, from: VMReminder, forcedResort resort: Bool) -> Result<Bool, Error>
	func remove(reminder: Reminder) -> Result<Bool, Error>
	func discard(reminder: Reminder)
	func isPending(reminder: VMReminder) -> Bool
}

private extension VMReminderList {
	class InternalProxy : VMReminderListInternal {
		var id: UUID { vmList?.id ?? UUID() }
		private(set) weak var vmList: VMReminderList?

		init(list: VMReminderList) {
			self.vmList = list
		}
		
		func asVMInternal(_ other: VMReminderList) -> any VMReminderListInternal {
			guard other !== vmList else { return self }
			return VMReminderList.InternalProxy(list: other)
		}
		
		func save(reminder: Reminder, from fromVM: VMReminder, forcedResort resort: Bool) -> Result<Bool, any Error> {
			guard let vmList else { return .failure(VMReminderStore.VMError.orphaned) }
			
			let sortedPos = vmList.reminders.firstIndex(of: fromVM)
			
			// - there are 3 possibilities for the reminder:
			//   1. not in sorted, meaning it is a transient reminder that needs to be appended to all lists (legacy approach)
			//   2. in sorted, but not in reminders, it is a new reminder with a specific sort position
			//   3. in sorted and in reminders, nothing to add
			if sortedPos == nil {
				// - option #1
				vmList._sortedReminders?.append(fromVM)
			}
			
			if let _ = vmList._sortedReminders?.firstIndex(of: fromVM), !(vmList._rawReminders?.contains(fromVM) ?? false) {
				// - option #1, #2
				vmList.model.reminders.append(reminder)
				let updSorted = vmList.reminders
				vmList.syncModelItemsAndSortOrder(withSorted: updSorted)
				
			} else if resort {
				vmList._sortedReminders = nil
				
			}
			
			return vmList.save()
		}
		
		func remove(reminder: Reminder) -> Result<Bool, any Error> {
			guard let vmList else { return .failure(VMReminderStore.VMError.orphaned) }
			guard let idx = vmList.model.reminders.firstIndex(where: {$0.id == reminder.id}) else {
				return .success(true)
			}
			vmList.model.reminders.remove(at: idx)
			return vmList.save()
		}
		
		func discard(reminder: Reminder) {
			guard let vmList else { return }
			if let _ = vmList._sortedReminders?.firstIndex(where: {$0.id == reminder.id}), vmList._rawReminders?.firstIndex(where: {$0.id == reminder.id}) == nil {
				vmList._sortedReminders = nil
			}			
		}
		
		func isPending(reminder: VMReminder) -> Bool {
			if let _ = vmList?._sortedReminders?.firstIndex(of: reminder), !(vmList?._rawReminders?.contains(reminder) ?? false) {
				return true
			}
			return false
		}
	}
}
