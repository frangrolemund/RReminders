//
//  _VExpObservable3.swift
//  RReminders
//
//  Created by Francis Grolemund on 4/23/25.
//

import SwiftUI


// - highlights that ObservableObject by default triggers updates
//   across all Views whether or not they are affected by the modification
// - taken from: https://fatbobman.com/en/posts/new-frameworks-new-mindset/
fileprivate struct _VExpObservable3: View {
	@StateObject var store = Store()
    var body: some View {
		VStack {
			NameView(store: store)
			AgeView(store: store)
			
			Button("Change Age") {
				store.updateAge()
			}
		}
    }
}

#Preview {
    _VExpObservable3()
}

fileprivate final class Store: ObservableObject {
  @Published var name = "Fei Fei"
  @Published var age = 5
  
  func updateAge() {
  	age += 1
  }
}

fileprivate struct NameView: View {
  @ObservedObject var store: Store
  var body: some View {
    let _ = print("NameView Update")
    Text(store.name)
  }
}

fileprivate struct AgeView: View {
  @ObservedObject var store: Store
  var body: some View {
    let _ = print("AgeView Update")
    Text(store.age, format: .number)
  }
}
