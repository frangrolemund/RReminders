//
//  _VExpObservable2.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/11/25.
//

import SwiftUI

// - this is an experiment in how Observability works and whether
//   it can be used with computed properties of Observable objects.

// - this proves that there is a strong relationship between Observables in
//   a hierarchy that is largely managed by the compiler and that SwiftUI
//   will only update views that explicitly reference those properties.

//  - in my mind this makes a _very strong_ argument for @Observable adoption
//    even in 'DTO' scenarios so that events are propagated when necessary to
//    the UI.
fileprivate struct _VExpObservable2: View {
	@Environment(Combo.self) var combo: Combo
	
    var body: some View {
    	List {
    		Section {
				Text("name = \(combo.name), age = \(combo.age)")
				Text("pet = \(combo.pet), games = \(combo.videoGames)")
    			
    			Button {
    				Task {
						let je = JSONEncoder()
						let jd = try je.encode(combo)
						print("ENCODED: \(String(data: jd, encoding: .utf8) ?? "n/a")")
    				}
    			} label: {
    				Text("Encode")
    			}
    			.buttonStyle(.bordered)
    			
			} header: {
				Text("Combo")
			}
    	
    		Section {
				Group1(combo: combo)
			} header: {
				Text("Group 1")
			}
			
			Section {
				Group2(combo: combo)
			} header: {
				Text("Group 2")
			}
    	}
    }
}

fileprivate struct Group1: View {
	let combo: Combo
	
	var body: some View {
		VStack(alignment: .leading) {
			Button {
				combo.baz.pet = String(UUID().uuidString.prefix(10))
				combo.baz.videoGames.toggle()
			} label: {
				Text("Modify Group2")
			}
			.buttonStyle(.bordered)

			Text("Name: \(combo.foo.name)")
			Text("Age: \(combo.foo.age)")
			
			Button {
				print("toggle unused in group2, should not modify border")
				combo.baz.chickenWings = Int.random(in: 1..<100)
			} label: {
				Text("Modify Group2 Unused Wings")
			}
			.buttonStyle(.bordered)
			
			Button {
				combo.bar.baz.pet = "X" + String(UUID().uuidString.prefix(10))
				combo.bar.baz.videoGames.toggle()
			} label: {
				Text("Modify Group2 from deeper reference")
			}
			.buttonStyle(.bordered)
		}
		.padding()
		.border(randomColor(), width: 2)
	}
}

// - by assigning a random color to the border each time it is drawn, we get a
//   very clear indicator it was redrawn.
fileprivate func randomColor() -> SwiftUI.Color {
	let colors: [Color] = [.red, .green, .blue, .purple, .brown, .black, .teal, .orange, .pink]
	return colors.randomElement() ?? Color.yellow
}

fileprivate struct Group2: View {
	let combo: Combo

	var body: some View {
		VStack(alignment: .leading) {
			Button {
				combo.name = String(UUID().uuidString.prefix(10))
				combo.age = Int.random(in: 3..<79)
			} label: {
				Text("Modify Group1")
			}
			.buttonStyle(.bordered)

			Text("Pet: \(combo.baz.pet)")
			Text("Video Games: \(combo.baz.videoGames)")
			
			Button {
				print("toggle unused in group1, should not modify border")
				combo.foo.isMale.toggle()
			} label: {
				Text("Modify Group1 Unused Sex")
			}
			.buttonStyle(.bordered)
			
			Button {
				combo.bar.foo.name = "Y" + String(UUID().uuidString.prefix(10))
				combo.bar.foo.age = Int.random(in: 3..<79)
			} label: {
				Text("Modify Group1 from deeper reference")
			}
			.buttonStyle(.bordered)
		}
		.padding()
		.border(randomColor(), width: 2)
	}
}

@Observable
fileprivate class Combo: Codable {
	var name: String {
		get { foo.name }
		set { foo.name = newValue }
	}
	
	var age: Int {
		get { foo.age }
		set { foo.age = newValue }
	}
	
	var pet: String {
		get { baz.pet }
		set { baz.pet = newValue }
	}
	
	var videoGames: Bool {
		get { baz.videoGames }
		set { baz.videoGames = newValue }
	}
	
	var foo: Foo
	var baz: Baz
	var bar: Bar
	
	init() {
		let foo = Foo()
		let baz = Baz()
		self.foo = foo
		self.baz = baz
		self.bar = .init(foo: foo, baz: baz)
	}
	
	private enum CodingKeys: String, CodingKey {
		case _foo = "foo"
		case _baz = "baz"
		case _bar = "bar"
	}
}


// - the DTO part, but as a reference so that there can be one instance
@Observable
fileprivate class Foo: Codable {
	var name: String
	var age: Int
	var isMale: Bool
	
	init() {
		name = "sample"
		age = 19
		isMale = false
	}
	
	private enum CodingKeys: String, CodingKey {
		case _name = "name"
		case _age = "age"
		case _isMale = "isMale"
	}
}

// - a different level of hiearchy that uses references to the others.
@Observable
fileprivate class Bar: Codable {
	var foo: Foo
	var baz: Baz
	
	init(foo: Foo, baz: Baz) {
		self.foo = foo
		self.baz = baz
	}
	
	private enum CodingKeys: String, CodingKey {
		case _foo = "foo"
		case _baz = "baz"
	}
}

@Observable
fileprivate class Baz: Codable {
	var pet: String
	var videoGames: Bool
	var chickenWings: Int
	
	init() {
		pet = "dog"
		videoGames = true
		chickenWings = 30
	}
	
//	required init(from decoder: any Decoder) throws {
//		let container = try decoder.container(keyedBy: CodingKeys.self)
//		self.pet = try container.decode(String.self, forKey: .pet)
//		self.videoGames = try container.decode(Bool.self, forKey: .videoGames)
//		self.chickenWings = try container.decode(Int.self, forKey: .chickenWings)
//	}
//	
//	func encode(to encoder: any Encoder) throws {
//		var container = encoder.container(keyedBy: CodingKeys.self)
//		try container.encode(pet, forKey: .pet)
//		try container.encode(videoGames, forKey: .videoGames)
//		try container.encode(chickenWings, forKey: .chickenWings)
//	}
		
	private enum CodingKeys: String, CodingKey {
		case _pet			= "pet"
		case _videoGames    = "videoGames"
		case _chickenWings  = "chickenWings"
	}
}


#Preview {
    _VExpObservable2()
		.environment(Combo())
}
