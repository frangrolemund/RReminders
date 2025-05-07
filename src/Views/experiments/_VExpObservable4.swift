//
//  _VExpObservable4.swift
//  RReminders
//
//  Created by Francis Grolemund on 4/23/25.
//

import SwiftUI

// - highlights that Observable conformance allows more precise notification
//   and simplfies usage in dependent scenarios.
// - taken from: https://fatbobman.com/en/posts/new-frameworks-new-mindset/
fileprivate struct _VExpObservable4: View {
	@State var store = Store()
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
    _VExpObservable4()
}

@Observable fileprivate final class Store {
  var name = "Fei Fei 2"
  var age = 5
  
  func updateAge() {
  	age += 1
  }
}

fileprivate struct NameView: View {
  let store: Store
  var body: some View {
    let _ = print("NameView Update v2")
    Text(store.name)
  }
}

fileprivate struct AgeView: View {
  let store: Store
  var body: some View {
    let _ = print("AgeView Update v2")
    Text(store.age, format: .number)
  }
}
