//
//  _VExpObservable6.swift
//  RReminders
//
//  Created by Francis Grolemund on 4/27/25.
//

import SwiftUI

fileprivate struct _VExpObservable6: View {
	@State private var model: ExpModel = .init()
	@State private var text: String = ""
    var body: some View {
		NavigationStack {
			VStack(spacing: 20) {
				Spacer()
					.frame(height: 40)
				HStack {
					TextField("Item", text: $text)
						.textFieldStyle(.roundedBorder)
						.textContentType(.none)
						.textCase(.none)
					Button("Add Item") {
						model.addItem(text)
						text = ""
						print("updated model #2 using \(Array(model.indices)):")
						for s in model {
							print("- \(s)")
						}
					}
				}
				
				InnerView(model: model)
				OuterView(model: model)
			}
			.listStyle(.plain)
			.padding()
			.toolbar {
				ToolbarItem {
					EditButton()
				}
			}
		}
    }
}

fileprivate struct _VExpObservable6a: View {
	@State private var fruits = [
		"Apple",
		"Banana",
		"Papaya",
		"Mango"
	]


	var body: some View {
		NavigationView {
			List {
				ForEach(fruits, id: \.self) { fruit in
					Text(fruit)
				}
				.onDelete { fruits.remove(atOffsets: $0) }
				.onMove { fruits.move(fromOffsets: $0, toOffset: $1) }
			}
			.navigationTitle("Fruits")
			.toolbar {
				EditButton()
			}
		}
	}
}

// - displays the model data using an inner property expressed as
//   a collection.
fileprivate struct InnerView: View {
	let model: ExpModel
	
	var body: some View {
		VStack {
			Text("Model Inner Collection:")
				.font(.title3)
     				
			List {
				ForEach(model.sorted, id: \.self) { item in
					Text("- \(item)")
				}
				.onMove { iSet, idx in
					print("move \(iSet), \(idx)")
				}
			}
			.border(.darkGray)
		}
	}
}

// - displays the model using the model _as the collection_
fileprivate struct OuterView: View {
	let model: ExpModel
	
	var body: some View {
		VStack {
			Text("Model as Collection:")
				.font(.title3)

			// - the List/ForEach collections do not appear to work
			//   by default using the @Observable model itself, which
			//   is why it is converted to an Array here.  The ObservableObject
			//   pattern does work as-is, but expects the older patterns of @Published
			//   and @ObservedObject.
			// - the move support won't work in the canvas, only the real app, btw
			List {
//				ForEach(Array(model), id: \.self) { item in
				ForEach(model, id: \.self) { item in
					Text("- \(item)")
				}
				.onMove { idxSet, idx in
					print("move \(idxSet), \(idx)")
				}
			}
			.border(.darkGray)
		}
	}
}

#Preview {
	@Previewable @State var model = ExpModel()
    _VExpObservable6()
}

#Preview("Ref-Move") {
	_VExpObservable6a()
}

@Observable
fileprivate final class ExpModel: RandomAccessCollection {
	typealias Element = String
	
	var startIndex: Int { 0 }
	var endIndex: Int { sorted.count }
	
	init() {
		_listData = ["apple", "yellow", "about"]
	}
	
	subscript(_ position: Int) -> String {
		sortedData()[position]
	}
	
	var sorted: [String] {
		sortedData()
	}
	
	func addItem(_ item: String) {
		_listData.append(item)
		_sorted = nil
	}

	private var _listData: [String]
	private var _sorted: [String]?
	
	private func sortedData() -> [String] {
		if let ret = _sorted { return ret }
		let ret = _listData.sorted()
		_sorted = ret
		return ret
	}
}
