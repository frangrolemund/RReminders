//
//  ReminderModelTests.swift
//  RRemindersTests
//
//  Created by Francis Grolemund on 4/24/25.
//

import XCTest
import SwiftData
@testable import RReminders

final class ReminderModelTests: XCTestCase {
	fileprivate static var toDelete: [URL] = []
		
	override class func tearDown() {
		guard let first = toDelete.first else { return }
		let items = try! FileManager.default.contentsOfDirectory(at: first.deletingLastPathComponent(), includingPropertiesForKeys: nil)
		for u in toDelete {
			let f = u.lastPathComponent
			for dbf in items.filter({$0.absoluteString.contains(f)}) {
				try! FileManager.default.removeItem(at: dbf)
			}
		}
	}

	// - just verify the test behavior.
	func testStacks() throws {
		var urls: [URL] = []
		if true {
			let ms1 = ModelStack()
			ms1.reopen()
			let ms2 = ModelStack()
			ms2.reopen()
			ms2.reopen()
			let ms3 = ModelStack()
			for m in [ms1, ms2, ms3] {
				let u = m.url
				XCTAssertTrue(FileManager.default.fileExists(atPath: u.path))
				urls.append(u)
			}
		}
	}
	
	// - verify the basic model behavior, independent of the viewmodel
	func testBasicModelOps() throws {
		let ms = ModelStack()
		
		var modCat: [ReminderStore.SummaryCategory] = []
		
		// - set up some test relationships.
		if true {
			let s = ms.store
			ms.store.summaryCategories = [s.summaryCategories[3], s.summaryCategories[2], s.summaryCategories[1], s.summaryCategories[0]]
			ms.store.summaryCategories.forEach { modCat.append($0.id) }
			ms.store.summaryCategories[1].isVisible = false
			ms.store.summaryCategories[3].isVisible = false
			
			let l1 = ReminderList(name: "Reminders")
			s.lists.append(l1)
			ms.save()
			
			let l2 = ReminderList(name: "Hotlist")
			s.lists.append(l2)
			ms.save()
			
			let l1ref = s.lists[0]
			XCTAssertTrue(l1 === l1ref)
			
			let l2ref = s.lists[1]
			XCTAssertTrue(l2 === l2ref)
			XCTAssertEqual(s.lists[0].name, "Reminders")
			XCTAssertEqual(s.lists[1].name, "Hotlist")
			
			l1.reminders.append(Reminder(title: "Dog food"))
			l1.reminders.append(Reminder(title: "Post office"))
			l1.reminders.append(Reminder(title: "Dentist", priority: .high))
			
			l2.reminders.append(Reminder(title: "Taxes", priority: .low))
			l2.reminders.append(Reminder(title: "Vacation", priority: .high))
			ms.save()
		}
		
		// - verify that once reopened, we can get to and modify them.
		ms.reopen()
		if true {
			let rs = ms.store
			XCTAssertTrue(rs.summaryCategories[0].isVisible)
			XCTAssertFalse(rs.summaryCategories[1].isVisible)
			XCTAssertTrue(rs.summaryCategories[2].isVisible)
			XCTAssertFalse(rs.summaryCategories[3].isVisible)
			for i in 0..<modCat.count {
				XCTAssertEqual(modCat[i], rs.summaryCategories[i].id)
			}
			
			XCTAssertTrue(rs.lists.count == 2)
			XCTAssertEqual(rs.lists[0].name, "Reminders")
			rs.lists[0].name = "Important"
			XCTAssertEqual(rs.lists[1].name, "Hotlist")
			
			XCTAssertTrue(rs.lists[0].reminders.count == 3)
			XCTAssertEqual(rs.lists[0].reminders[0].title, "Dog food")
			XCTAssertEqual(rs.lists[0].reminders[0].priority, nil)
			XCTAssertEqual(rs.lists[0].reminders[1].title, "Post office")
			rs.lists[0].reminders[1].title = "Mail letters"
			XCTAssertEqual(rs.lists[0].reminders[2].title, "Dentist")
			XCTAssertEqual(rs.lists[0].reminders[2].priority, .high)
			rs.lists[0].reminders.removeFirst()
			
			XCTAssertTrue(rs.lists[1].reminders.count == 2)
			XCTAssertEqual(rs.lists[1].reminders[0].title, "Taxes")
			XCTAssertEqual(rs.lists[1].reminders[0].priority, .low)
			rs.lists[1].reminders[0].priority = .medium
			XCTAssertEqual(rs.lists[1].reminders[1].title, "Vacation")
			XCTAssertEqual(rs.lists[1].reminders[1].priority, .high)
			ms.save()
		}
		
		// - verify that modifications took effect.
		ms.reopen()
		if true {
			let rsa = try ms.context.fetch(FetchDescriptor<ReminderStore>())
			XCTAssertTrue(rsa.count == 1)
			let rs = rsa[0]
			XCTAssertTrue(rs.lists.count == 2)
			XCTAssertEqual(rs.lists[0].name, "Important")
			
			XCTAssertTrue(rs.lists[0].reminders.count == 2)
			XCTAssertTrue(rs.lists[1].reminders.count == 2)
			
			XCTAssertEqual(rs.lists[0].reminders[0].title, "Mail letters")
			XCTAssertEqual(rs.lists[1].reminders[0].priority, .medium)
		}
	}
	
	func testViewModelStoreOps() throws {
		let ms = ModelStack()
		
		var modCat: [ReminderStore.SummaryCategory] = []
		if true {
			let vrs = VMReminderStore(store: ms.store, context: ms.context)
		
			// s:r1: add list
			let l1 = vrs.addReminderList(name: "Reminders")
			XCTAssertNoThrow(try l1.save().get())
			
			// r2: create/edit, make changes to name/color and save
			l1.color = .purple
			l1.name = "Reminders!"
			XCTAssertNoThrow(try l1.save().get())
			
			// r1: create/edit, make changes to name/color and discard
			let l2 = vrs.addReminderList(name: "Invalid", color: .orange)	// - not saved, so discarded
			let _ = l2.addReminder(title: "Do nothing")
			let _ = l2.addReminder(title: "Ignore")
			
			// r1: add list
			let l3 = vrs.addReminderList(name: "Alternate")
			XCTAssertNoThrow(try l3.save().get())
			let l4 = vrs.addReminderList(name: "Final")
			let r4a = l4.addReminder(title: "Final save only")				// - save the list by saving the reminder
			XCTAssertNoThrow(try r4a.save().get())
			
			// r4: order, show/hide categories (autosave)
			XCTAssertTrue(vrs.hasVisibleCategories)
			vrs.summaryCategories = [vrs.summaryCategories[2], vrs.summaryCategories[3], vrs.summaryCategories[1], vrs.summaryCategories[0]]
			vrs.summaryCategories.forEach({modCat.append($0.id)})
			for i in 0..<vrs.summaryCategories.count {
				vrs.summaryCategories[i].isVisible = false
			}
			XCTAssertFalse(vrs.hasVisibleCategories)
			vrs.summaryCategories[3].isVisible = true
		}
		
		// - verify the state of the content.
		ms.reopen()
		if true {
			let vms = VMReminderStore(store: ms.store, context: ms.context)
			XCTAssertEqual(vms.lists.count, 3)
			XCTAssertEqual(vms.lists[0].name, "Reminders!")
			XCTAssertEqual(vms.lists[0].color, .purple)

			XCTAssertEqual(vms.lists[1].name, "Alternate")
			XCTAssertEqual(vms.lists[1].color, .blue)
			
			XCTAssertEqual(vms.lists[2].name, "Final")
			XCTAssertEqual(vms.lists[2].color, .blue)
		
			for i in 0..<modCat.count {
				XCTAssertEqual(vms.summaryCategories[i].id, modCat[i])
				XCTAssertEqual(vms.summaryCategories[i].isVisible, i == 3)
			}
			
			// r3: reorder lists (autosave)
			vms.lists = vms.lists.reversed()
			
			// r2: delete list (autosave)
			vms.lists.remove(at: 1)
		}
	}
	
	func testViewModelListOps() throws {
		let ms = ModelStack()
		
		if true {
			let vms = VMReminderStore(store: ms.store, context: ms.context)
		
			// r1: create/edit, make changes to name/color and discard
			let l1 = vms.addReminderList(name: "Sports List")
			l1.name = "Team List"
			l1.color = .brown
			
			// r2: create/edit, make changes to name/color and save
			let l2 = vms.addReminderList(name: "Animals")
			XCTAssertNoThrow(try l2.save().get())
			l2.name = "Pets"
			l2.color = .red
			XCTAssertNoThrow(try l2.save().get())
			
			// r5: change sort order (autosave)
			l2.sortOrder = .priority
			
			// r7: show/hide completed (autosave)
			l2.showCompleted = true
			
			// r2: create/edit and save
			let l3 = vms.addReminderList(name: "Cars", color: .green)
			l3.name = "Classic Cars"
			XCTAssertNoThrow(try l3.save().get())
			
			// r2: create/edit and save
			let l4 = vms.addReminderList(name: "Reminders")
			XCTAssertNoThrow(try l4.save().get())
		}
		
		ms.reopen()
		if true {
			let vms = VMReminderStore(store: ms.store, context: ms.context)
			XCTAssertEqual(vms.lists.count, 3)
			XCTAssertEqual(vms.lists[0].name, "Pets")
			XCTAssertEqual(vms.lists[0].color, .red)
			XCTAssertEqual(vms.lists[0].sortOrder, .priority)
			XCTAssertEqual(vms.lists[0].showCompleted, true)
			XCTAssertEqual(vms.lists[1].name, "Classic Cars")
			XCTAssertEqual(vms.lists[1].color, .green)
			XCTAssertEqual(vms.lists[1].sortOrder, .manual)
			XCTAssertEqual(vms.lists[1].showCompleted, false)
			XCTAssertEqual(vms.lists[2].name, "Reminders")
			XCTAssertEqual(vms.lists[2].color, .blue)
		}
	}
	
	// - the custom remind-on type is somehow related to firing a breakpoint deep in CoreData
	// - this verifies there's nothing funny with it.
	func testTypeDecoding() throws {
		let assertCodable = {(item: Reminder.RemindOn) in
			let je = JSONEncoder()
			var d: Data!
			XCTAssertNoThrow(d = try je.encode(item))
		
			let jd = JSONDecoder()
			var memorex: Reminder.RemindOn!
			XCTAssertNoThrow(memorex = try jd.decode(Reminder.RemindOn.self, from: d!))
			
			XCTAssertEqual(item, memorex!)
		}
	
		let n1 = Calendar.current.date(byAdding: .day, value: 1, to: .now, wrappingComponents: false)!
		try assertCodable(Reminder.RemindOn.date(date: n1, repeats: .never))
	}
	
	// - verifying a pattern that was failing from the viewmodel
	func testModelReminderOps() throws {
		let ms = ModelStack()
		
		let notifyOn = Calendar.current.date(byAdding: .day, value: 1, to: .now, wrappingComponents: false)!
		if true {
			let s = ms.store
			
			let l1 = ReminderList(name: "Test Reminders", color: .green)
			s.lists.append(l1)
			ms.save()
			
			let r1 = Reminder(title: "Groceries")
			l1.reminders.append(r1)
			ms.save()
			r1.notes = "Bread, milk, eggs."
			r1.priority = .medium
			r1.notifyOn = .date(date: notifyOn, repeats: .never)
			ms.save()
			
			let r2 = Reminder(title: "Mow lawn", notes: "Get gasoline")
			l1.reminders.append(r2)
			ms.save()
			
			let r3 = Reminder(title: "Walk dog", priority: .high)
			l1.reminders.append(r3)
			ms.save()
			
			let r4 = Reminder(title: "Pay bills", priority: .low)
			l1.reminders.append(r4)
			ms.save()
			
			XCTAssertEqual(s.lists[0].reminders.count, 4)
		}
		
		ms.reopen()
		if true {
			let s = ms.store
			XCTAssertEqual(s.lists.count, 1)
			XCTAssertEqual(s.lists[0].name, "Test Reminders")
			
			XCTAssertEqual(s.lists[0].reminders.count, 4)
			
			XCTAssertEqual(s.lists[0].reminders[0].title, "Groceries")
			XCTAssertEqual(s.lists[0].reminders[0].notes, "Bread, milk, eggs.")
			XCTAssertEqual(s.lists[0].reminders[0].priority, .medium)
			XCTAssertEqual(s.lists[0].reminders[0].notifyOn, .date(date: notifyOn, repeats: .never))
			
			XCTAssertEqual(s.lists[0].reminders[1].title, "Mow lawn")
			XCTAssertEqual(s.lists[0].reminders[1].notes, "Get gasoline")
			
			XCTAssertEqual(s.lists[0].reminders[2].title, "Walk dog")
			XCTAssertEqual(s.lists[0].reminders[2].priority, .high)
			
			XCTAssertEqual(s.lists[0].reminders[3].title, "Pay bills")
			XCTAssertEqual(s.lists[0].reminders[3].priority, .low)
			
			s.lists[0].reminders = s.lists[0].reminders.reversed()
			s.lists[0].reminders.remove(at: 2)
			ms.save()
		}
		
		ms.reopen()
		if true {
			let s = ms.store
			XCTAssertEqual(s.lists.count, 1)
			XCTAssertEqual(s.lists[0].name, "Test Reminders")
		
			XCTAssertEqual(s.lists[0].reminders.count, 3)
			XCTAssertNotNil(s.lists[0].reminders.firstIndex(where: {$0.title == "Pay bills"}))
			XCTAssertNotNil(s.lists[0].reminders.firstIndex(where: {$0.title == "Walk dog"}))
			XCTAssertNotNil(s.lists[0].reminders.firstIndex(where: {$0.title == "Groceries"}))
		}
	}
	
	func testViewModelReminderOps() throws {
		let ms = ModelStack()
		
		let notifyOn = Calendar.current.date(byAdding: .day, value: 1, to: .now, wrappingComponents: false)!
		if true {
			let vms = VMReminderStore(store: ms.store, context: ms.context)
			
			let l1 = vms.addReminderList(name: "Test Reminders", color: .green)
			XCTAssertNoThrow(try l1.save().get())
			
			let r1 = l1.addReminder(title: "Groceries")
			XCTAssertNoThrow(r1.save())
			r1.notes = "Bread, milk, eggs."
			r1.priority = .medium
			r1.notifyOn = .date(date: notifyOn)
			r1.save()
			
			let r2 = l1.addReminder(title: "Mow lawn", notes: "Get gasoline")
			r2.save()
			
			let r3 = l1.addReminder(title: "Walk dog", priority: .high)
			r3.save()
			
			let r4 = l1.addReminder(title: "Pay bills", priority: .low)
			r4.save()
			
			XCTAssertEqual(vms.lists[0].reminders.count, 4)
		}
		
		ms.reopen()
		if true {
			let vms = VMReminderStore(store: ms.store, context: ms.context)
			XCTAssertEqual(vms.lists.count, 1)
			XCTAssertEqual(vms.lists[0].name, "Test Reminders")
			
			XCTAssertEqual(vms.lists[0].reminders.count, 4)
			XCTAssertEqual(vms.lists[0].reminders[0].title, "Groceries")
			XCTAssertEqual(vms.lists[0].reminders[0].notes, "Bread, milk, eggs.")
			XCTAssertEqual(vms.lists[0].reminders[0].priority, .medium)
			XCTAssertEqual(vms.lists[0].reminders[0].notifyOn, .date(date: notifyOn))
			
			XCTAssertEqual(vms.lists[0].reminders[1].title, "Mow lawn")
			XCTAssertEqual(vms.lists[0].reminders[1].notes, "Get gasoline")
			
			XCTAssertEqual(vms.lists[0].reminders[2].title, "Walk dog")
			XCTAssertEqual(vms.lists[0].reminders[2].priority, .high)
			
			XCTAssertEqual(vms.lists[0].reminders[3].title, "Pay bills")
			XCTAssertEqual(vms.lists[0].reminders[3].priority, .low)
			
			vms.lists[0].reminders = vms.lists[0].reminders.reversed()
			vms.lists[0].reminders.remove(at: 2)
			vms.save()
		}
		
		ms.reopen()
		if true {
			let vms = VMReminderStore(store: ms.store, context: ms.context)
			XCTAssertEqual(vms.lists.count, 1)
			XCTAssertEqual(vms.lists[0].name, "Test Reminders")
		
			XCTAssertEqual(vms.lists[0].reminders.count, 3)
			XCTAssertEqual(vms.lists[0].reminders[0].title, "Pay bills")
			XCTAssertEqual(vms.lists[0].reminders[1].title, "Walk dog")
			XCTAssertEqual(vms.lists[0].reminders[2].title, "Groceries")
		}	
	}
}

private extension ReminderModelTests {
	class ModelStack {
		let url: URL
		private(set) var container: ModelContainer!
		private(set) var context: ModelContext!
	
		init() {
			var base: URL!
			XCTAssertNoThrow(base = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true))
			let u = base.appending(path: "model-\(UUID().uuidString)")
			self.url = u
			print("UT: initializing model stack located at \(u.path(percentEncoded: false))")
			self.reopen()
		}
		
		// - repopen the container/context to verify persistence.
		func reopen() {
			if self.container != nil {
				print("UT: closing/reopening model stack.")
			}
			self.container = nil
			self.context   = nil
			self._store    = nil
			XCTAssertNoThrow(self.container = try ModelContainer(for: ReminderStore.self, configurations: ModelConfiguration(url: self.url)))
			self.context = ModelContext(self.container)
			XCTAssertNotNil(self.container)
			XCTAssertNotNil(self.context)
		}
		
		func save() {
			XCTAssertNoThrow(try self.context.save())
		}
		
		var store: ReminderStore {
			if let rs = _store { return rs }
			do {
				let ret = try context.fetch(FetchDescriptor<ReminderStore>())
				if ret.count == 0 {
					let newS = ReminderStore()
					context.insert(newS)
					try context.save()
					_store = newS
					return newS
				
				} else {
					XCTAssertTrue(ret.count == 1)
					_store = ret.first!
					return _store!
					
				}
			} catch {
				XCTAssertTrue(false)
				return ReminderStore()
			}
		}
		private var _store: ReminderStore?
		
		deinit {
			ReminderModelTests.toDelete.append(url)
		}
	}
	
}
