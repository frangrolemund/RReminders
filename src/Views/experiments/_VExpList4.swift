//
//  _VExpList4.swift
//  RReminders
//
//  Created by Francis Grolemund on 4/30/25.
//

import SwiftUI

fileprivate let sections: [SimpleId]    = [.init("Most Important"), .init("Next Important"), .init("Least Important")]
fileprivate let subSections: [SimpleId] = [.init("Good"), .init("Bad"), .init("Indifferent")]
fileprivate let animals: [SimpleId]     = [.init("elephant"), .init("cat"), .init("monkey"), .init("chimpanzee")]

struct SimpleId: Identifiable {
	let id: UUID = .init()
	let text: String
	
	init(_ text: String) {
		self.text = text
	}
}

// - lists with sections, sub-sections?
fileprivate struct _VExpList4: View {
    var body: some View {
    	NavigationStack {
			List {
				ForEach(sections) { sec in
					Section(sec.text) {
						ForEach(subSections) { subSec in
							Section(subSec.text) {
								ForEach(animals) { animal in
									Text("--> \(animal.text)")
								}
							}
						}
					}
				}
				ForEach(animals) { animal in
					Text("XXX \(animal.text)")
				}
			}
			.listStyle(.plain)
			.navigationTitle("Sample")
    	}
    }
}

#Preview {
    _VExpList4()
}
