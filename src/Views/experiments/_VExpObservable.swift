//
//  _VExpObservable.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/10/25.
//

import SwiftUI

// - this is an experiment in how Observability works and whether
//   it can be used with computed properties of Observable objects.
// - it also experiments with concurrent patterns

fileprivate struct _VExpObservable: View {
	@Environment(Bar.self) var data: Bar
	
    var body: some View {
		VStack {
			BView(data: data)
			Text("\(data.computedString)")
		}
    }
}

fileprivate struct BView : View {
	var data: Bar
	
	var body: some View {
		Button {
			Task.detached {
				let enc = try await data.encoded()
				print("ENCODED --> \(String(data: enc, encoding: .utf8)!)")
			}
			data.name = "amanda-" + UUID().uuidString
		} label: {
			Text("Modify")
		}
	}
}

#Preview {
	_VExpObservable()
		.environment(Bar())
}

// - the interface to the UI.
// - since this uses the @MainActor macro, it is implicitly Sendable and
//   synchronized with the main thread.
@MainActor
fileprivate class Bar: LockedObservable {
	private var foo: Foo = .init()
	
	// - note the pattern here to plug-into observability using syntax that
	//   feels expressive, trivially wrapping the internal object call.
	var name: String {
		get { dto(get) { foo.name } }
		set { dto(set) { foo.name = newValue } }
	}

	var computedString: String {
		return "\(self.name) + \(foo.age)"
	}
	
	func encoded() throws -> Data {
		let je = JSONEncoder()
		return try je.encode(foo)
	}
}


// - the DTO part, but as a reference so that there can be one instance
fileprivate class Foo: Codable {
	var name: String
	var age: Int
	var isMale: Bool
	var baz: Baz
	
	init() {
		name = "sample"
		age = 19
		isMale = false
		baz = .init()
	}	
}

// - this 'DTO' part is an interesting case study when you look at the
//   encoding.  The act of making it @Observable _changes the encoded structure_
//   because it presumably auto-assigns property wrappers to all the enclosed
//   properties.  Each property gets prefixed with an underscore and it gains
//   a weird _$observationRegistrar property that also gets encoded.  These
//   facts strongly suggest that @Observables *should never* be encoded as a rule
//   and weren't intended to be.
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

	private enum CodingKeys: String, CodingKey {
		case _pet = "pet"
		case _videoGames = "videoGames"
		case _chickenWings = "chickenWings"
	}
}


// - in order for an @Observable class to publish content, it must modify a
//   value or another @Observable type in one of its properties.  If we're
//   maintaining a property in an observable instance that might be shared with
//   a background thread, we need to (a) protect that access and (b) signal when
//   changes occured.  The former requires a lock and the latter some minor
//   scratchpad item to trigger the observability.
// - NOTE:  after having experimented with this idea of locking, I realize that
//   it is not necessary if the sub-class is designated as @MainActor and we're
//   using swift concurrency.  The more important detail is how the observable
//   class can be 'triggered' by changing and _referencing_ an internal
//   attribute because it appears the compiler is smart enough to detect when
//   the reference is used (in computed sub-properties) to know if those computed
//   properties should partcipate in a redraw.
@Observable
fileprivate class LockedObservable {
	// - the code here exists to support two types of calling conventions for
	//   sub-classes' computed properties:
	//   1.  dto(get) { return <data> }			// - read the current data
	//   2.  dto(set) { <data> = newValue }		// - publish a change

	private(set) var get: Int = 0
	let set: Bool = true
	
	private let _lock: NSLock = .init()
	
	func dto<T>(_ rdwr: Bool, block: () -> T) -> T {
		return dto(0, set, block: block)
	}
				
	func dto<T>(_ c: Int, _ rdwr: Bool = false, block: () -> T) -> T {
		_lock.lock()
		defer { _lock.unlock() }
		if rdwr {
			get += 1
		}
		return block()
	}
}
