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
	
	func append(_ reminder: VMReminder) {
		reminders.append(reminder)
	}
	
	private let store: any VMReminderStoreInternal
	private let model: ReminderList
	private var _pendingName: String?
	private var _pendingColor: ReminderList.Color?
	private var _reminders: [VMReminder]?
	private var _sortedReminders: [VMReminder]?
}


// - types/accessors
extension VMReminderList {		
	var startIndex: Int { reminders.startIndex }
	var endIndex: Int { reminders.endIndex }
	var count: Int { reminders.count }
	
	var reminders: [VMReminder] {
		get { sortedReminders }
		
		set {
			// - this operation is necessary to allow reordering, but it needs to be done
			//   carefully to ensure the backing data is consistent.
			newValue.forEach({$0.save()})
			model.reminders = newValue.map({ vmr in
				model.reminders.first { r in
					r.id == vmr.id
				}!
			})
			_reminders = newValue
			_sortedReminders = nil
			self.save()
		}
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
		if let tmp = _reminders {
			unsorted = tmp
			
		} else {
			unsorted = model.reminders.map({VMReminder(list: InternalProxy(list: self), reminder: $0)})
			_reminders = unsorted
			
		}
		
		let resorted: [VMReminder]
		switch sortOrder {
		case .manual:
			resorted = unsorted.sorted(by: { r1, r2 in
				(!r1.isCompleted || r2.isCompleted)
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
	
	func addReminder(title: String = "", notes: String? = nil, notifyOn: Reminder.RemindOn? = nil, priority: Reminder.Priority? = nil, completedOn: Date? = nil) -> VMReminder {
		VMReminder(list: InternalProxy(list: self), title: title, notes: notes, notifyOn: notifyOn, priority: priority, completedOn: completedOn)
	}
}

protocol VMReminderListInternal : AnyObject, Identifiable {
	var id: UUID { get }
	var vmList: VMReminderList? { get }
	func asVMInternal(_ other: VMReminderList) -> any VMReminderListInternal
	func save(reminder: Reminder, from: VMReminder, forcedResort resort: Bool) -> Result<Bool, Error>
	func remove(reminder: Reminder) -> Result<Bool, Error>
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
		
		func save(reminder: Reminder, from: VMReminder, forcedResort resort: Bool) -> Result<Bool, any Error> {
			guard let vmList else { return .failure(VMReminderStore.VMError.orphaned) }
			
			if vmList.reminders.firstIndex(of: from) == nil {
				var tmp = vmList.reminders
				tmp.append(from)
				reminder.list = vmList.model
				vmList.model.reminders.append(reminder)
				vmList._reminders = tmp
				vmList._sortedReminders = nil
				
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
	}
}
