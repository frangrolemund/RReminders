//
//  _VExpNav.swift
//  RReminders
//
//  Created by Francis Grolemund on 4/23/25.
//

import SwiftUI

fileprivate struct _VExpNav: View {
	@State private var path: NavigationPath = .init() {
		didSet {
			// - only fired when the path is modified by changing the value.
			emitState("DidSet")
		}
	}
    var body: some View {
		NavigationStack(path: $path) {
			List {
				Text("ONE")
				
				HStack {
					Text("TWO - tappable")
					Spacer()
				}
				.contentShape(Rectangle())
				.onTapGesture {
					path.append(5)
				}
				
				NavigationLink("THREE - LINK", value: 104)
			
				// - proves that links can still be used, but do not influence the
				//   NavigationPath
				NavigationLink("Four - Classic") {
					Text("Classic Link Destination")
						.foregroundStyle(.white)
						.background {
							Color.blue
						}
				}
			}
			.navigationDestination(for: Int.self) { item in
				SubView(item: item)
			}
			.navigationTitle("Parent")
		}
		.task {
			// - this proves that the path will continue to be updated as we
			//   push further into the stack although the `didSet` on the state
			//   will only occur when directly manipulated.
			while !Task.isCancelled {
				try? await Task.sleep(for: .seconds(2))
				emitState("Task")
			}
		}
		.onChange(of: path) { _, _ in
			// - this is fired reliably even when the path is set by a sub-view.
			emitState("OnChange")
		}
    }
    
	private func emitState(_ title: String) {
		guard path.count > 0 else { return }
		let je = JSONEncoder()
		let enc = (try? je.encode(path.codable)) ?? Data()
		let t = String(data: enc, encoding: .utf8)!
		print("\(title): COUNT = \(path.count) -> \(t)")
	}
}

fileprivate struct SubView: View {
	let item: Int
	var body: some View {
		List {
			VStack {
				Text("<-- BEGIN")
				Text("YOUR ITEM is -> \(item)")
				Text("END -->")
			}
			
			VStack {
				NavigationLink("Sub-Sub", value: "Deep in the dank dungeon")
			}
		}
		.navigationDestination(for: String.self) { item in
			// - this proves there can be support for different destination
			//   types at different levels of the stack, but as the other test
			//   also shows, there's no overriding.
			SubSub(item: item)
		}
		.navigationTitle("Sub")
	}
}

fileprivate struct SubSub: View {
	let item: String
	
	var body: some View {
		List {
			Text("Sub-sub as -> \(item)")
			NavigationLink("Alt Link", value: "From the Alt")
			NavigationLink("Alt-alt Date", value: Date())
		}
		.navigationDestination(for: String.self) { item in
			// - this proves you can't override the destination deeper in the stack
			//   because this is never hit.
			AltSub(item: item)
		}
		.navigationDestination(for: Date.self, destination: { item in
			// - but this proves you can add a new destination for a currently
			//   unhandled type.
			AltSubDate(item: item)
		})
		.navigationTitle("SubSub")
	}
}

fileprivate struct AltSub: View {
	let item: String
	var body: some View {
		Text("UNEXPECTED for \(item)")
			.navigationTitle("Unexpected Alt")
			.foregroundStyle(.white)
			.background {
				Color.red
			}
	}
}

fileprivate struct AltSubDate: View {
	let item: Date
	var body: some View {
		Text("ALTSub for \(item)")
			.navigationTitle("Date")
	}
}



#Preview {
    _VExpNav()
}
