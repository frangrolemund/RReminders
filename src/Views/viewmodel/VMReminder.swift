//
//  Reminder.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/11/25.
//

import Foundation

@Observable
final class VMReminder: Identifiable, Equatable {
	static func == (lhs: VMReminder, rhs: VMReminder) -> Bool {
		guard lhs !== rhs else { return true }
		return lhs.id == rhs.id &&
				lhs.created == rhs.created &&
				lhs.title == rhs.title &&
				lhs.notes == rhs.notes &&
				lhs.notifyOn == rhs.notifyOn &&
				lhs.priority == rhs.priority &&
				lhs.completedOn == rhs.completedOn
	}

	var id: UUID { model.id }
	var created: Date { model.created }
	var listOrder: Int { model.arrayOrder }
	
	var title: String {
		get { _pendingModel?.title ?? model.title }
		set { pending.title = newValue }
	}
	
	var notes: String? {
		get { _pendingModel?.notes ?? model.notes }
		set { pending.notes = newValue }
	}
	
	var notifyOn: Reminder.RemindOn? {
		get { _pendingModel?.notifyOn ?? model.notifyOn }
		set { pending.notifyOn = newValue }
	}
	
	var priority: Reminder.Priority? {
		get { _pendingModel?.priority ?? model.priority }
		set { pending.priority = newValue }
	}
	
	var completedOn: Date? {
		get {
			if let pm = _pendingModel {
				return pm.completedOn
			}
			return model.completedOn
		}
		set { pending.completedOn = newValue }
	}
	
	var list: VMReminderList! {
		get { self._pendingList?.vmList ?? self._list.vmList }
		set { self._pendingList = self._list.asVMInternal(newValue) }
	}
	
	// - only lists create these
	init(list: any VMReminderListInternal,
		id: UUID = .init(),
		created: Date? = nil,
		title: String,
		notes: String? = nil,
		notifyOn: Reminder.RemindOn? = nil,
		priority: Reminder.Priority? = nil,
		completedOn: Date? = nil) {
		self._list = list
		self.model = Reminder(id: id, created: created, title: title, notes: notes, notifyOn: notifyOn, priority: priority, completedOn: completedOn)
	}
	
	init(list: any VMReminderListInternal, reminder: Reminder) {
		model = reminder
		_list = list
	}

	private var _list: any VMReminderListInternal
	private var model: Reminder
	private var _pendingList: (any VMReminderListInternal)?	
	private var _pendingModel: Reminder?
}

// - types/computed
extension VMReminder {
	private var pending: Reminder {
		if let ret = _pendingModel { return ret }
		let ret = Reminder(title: model.title, notes: model.notes, notifyOn: model.notifyOn, priority: model.priority, completedOn: model.completedOn)
		_pendingModel = ret
		return ret
	}
			
	var isModified: Bool {
		if let pli = _pendingList?.id, list.id != pli {
			return true
		}
		
		if let pr = _pendingModel {
			if pr.title != model.title || pr.notes != model.notes || pr.notifyOn != model.notifyOn || pr.priority != model.priority || pr.completedOn != model.completedOn {
				return true
			}
		}
		
		return false
	}

	var allowCreation: Bool {
		return !(title.trimmingCharacters(in: .whitespacesAndNewlines)).isEmpty && self.list != nil
	}
	
	var allowCommit: Bool {
		allowCreation
	}

	var isCompleted: Bool {
		get { completedOn != nil }
		set {
			if newValue {
				completedOn = completedOn == nil ? Date() : completedOn
			} else {
				completedOn = nil
			}
			self.save(forcedResort: true)
		}
	}
		
	var dueDate: Date { notifyOn?.date ?? Date.distantFuture }
		
	@discardableResult func save(forcedResort resort: Bool = false) -> Result<Bool, Error> {
		// - swap lists first to remove it from the prior list
		if let pl = _pendingList, pl.id != _list.id {
			let ret = _list.remove(reminder: self.model)
			if !ret.isOk {
				return ret
			}
		}
	
		// - now save it in the active list
		self.model.title = self.title
		self.model.notes = self.notes
		self.model.notifyOn = self.notifyOn
		self.model.priority = self.priority
		self.model.completedOn = self.completedOn
		let ret = (self._pendingList ?? self._list).save(reminder: self.model, from: self, forcedResort: resort)
		self._pendingList = nil
		self._pendingModel = nil		
		return ret
	}
	
	func revert() {
		_pendingModel = nil
		_pendingList = nil
	}
}
