//
//  _VExpObservable5.swift
//  RReminders
//
//  Created by Francis Grolemund on 4/24/25.
//

import SwiftUI
import SwiftData
import Combine

// - this proves that @Observable supports property observers but @Model quietly
//   omitted support for it in spite of claiming Observable protocol compliance.
// - that's why my code silently broke after moving to a persistent model.
fileprivate struct _VExpObservable5: View {
	@State private var mg = ModelGroup()

    var body: some View {
		VStack(spacing: 20) {
			ClassicView(mc: mg.mc)
			DBView(md: mg.md)
			ClassicWDBView(mcd: mg.mcd)
			ClassicOODBView(mod: mg.mod)
			ClassicOODBViewNoRef(mod: mg.mod)
			
			Button("Modify Classic") {
				mg.mc.value += 1
			}
			
			Button("Modify DB") {
				mg.md.value += 1
			}
		}
    }
}

#Preview {
    _VExpObservable5()
}

@Observable
fileprivate class ModelClassic {
	private(set) var changes: Int
	var value: Int {
		didSet {
			changes += 1
		}
	}
	
	init() {
		changes = 0
		value = 0
	}
}

@Model
fileprivate final class ModelDB {
	private(set) var changes: Int = 0
	
	var value: Int {
		// - my theory is that @Model doesn't support property observers which
		//   will ignore this code.
		didSet {
			changes += 1
		}
	}

	init() {
		changes = 0
		value = 0
	}
}

// - this proves that an @Observable can contain a @Model and get notifications
//   for the model changes while providing computed properties that expose them,
//   supporting an MVVM relationship between this and the model.
@Observable
fileprivate class ModelClassicWDB {
	private let db: ModelDB
	
	init(db: ModelDB) {
		self.db = db
	}
	
	var value: Int { return db.value }
}

// - proves that the new SwiftData object can be embedded into an ObservableObject
//   and used without the @Published indicator and even mixed with @Published
//   properties if desired while reataining reactivity for the value
fileprivate class ModelOOWDB : ObservableObject {
	private(set) var db: ModelDB
	
	@Published var name: String = "Allison"
	
	init(db: ModelDB) {
		self.db = db
	}
	
	var value: Int { return db.value }
}


fileprivate final class ModelGroup {
	let mc: ModelClassic
	let md: ModelDB
	let mcd: ModelClassicWDB
	let mod: ModelOOWDB
	
	init() {
		let c = ModelClassic()
		let d = ModelDB()
		let mo = ModelOOWDB(db: d)
		let cd = ModelClassicWDB(db: d)
		
		mc = c
		md = d
		mcd = cd
		mod = mo
	}
}


fileprivate struct ClassicView : View {
	let mc: ModelClassic
	
	var body: some View {
		VStack {
			Text("Classic (Observable)")
				.font(.title2)
			HStack {
				Text("Value: \(mc.value)")
				Text("Changes: \(mc.changes)")
			}
		}
	}
}

fileprivate struct DBView : View {
	let md: ModelDB
	
	var body: some View {
		VStack {
			Text("DB (SwiftData)")
				.font(.title2)
				
			HStack {
				Text("Value: \(md.value)")
				Text("Changes: \(md.changes)")
			}
		}
	}
}

fileprivate struct ClassicWDBView : View {
	let mcd: ModelClassicWDB
	
	var body: some View {
		VStack {
			Text("Classic w/ DB (Observable + Model)")
				.font(.title2)
				
			HStack {
				Text("Value: \(mcd.value)")
			}
		}
	}
}

fileprivate struct ClassicOODBView : View {
	let mod: ModelOOWDB		// - not making this @ObservedObject hides the name rxns
	
	var body: some View {
		VStack {
			Text("Combine w/ DB (ObservableObject + Model)")
				.font(.title2)
				
			HStack {
				Text("Value: \(mod.value)")
			}
			
			Button("Modify Name") {
				mod.name = String(mod.name.reversed())
			}
		}
		.border(Color.random)
	}
}

fileprivate struct ClassicOODBViewNoRef : View {
	@ObservedObject var mod: ModelOOWDB
	
	var body: some View {
		VStack {
			Text("Combine w/ DB (ObservableObject + Model + No ref)")
				.font(.title2)
				
			HStack {
				Text("Text: \(mod.name)")
			}
		}
		.border(Color.random)
	}
}
