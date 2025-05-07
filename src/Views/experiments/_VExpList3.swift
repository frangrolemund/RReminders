//
//  _VExpList3.swift
//  RReminders
//
//  Created by Francis Grolemund on 4/23/25.
//

import SwiftUI

fileprivate struct _VExpList3: View {
	static let items = ["apple", "car", "bike", "zero", "mailbox", "crab"]
	@State private var isAscending: Bool = true {
		didSet {
			itemState = _VExpList3.resort(isAscending: isAscending)
		}
	}
	@State private var itemState: [String]
	
	init() {
		self.itemState = _VExpList3.resort(isAscending: true)
	}

    var body: some View {
		VStack {
			Button("Toggle Sort") {
				isAscending.toggle()
			}
			
			List(itemState, id: \.self) { item in
				Text("\(item)")
			}
		}
    }
    
	static func resort(isAscending: Bool) -> [String] {
		return items.sorted { i1, i2 in
			if isAscending {
				return i1 < i2
			} else {
				return i2 < i1
			}
		}
    }
}

#Preview {
    _VExpList3()
}
