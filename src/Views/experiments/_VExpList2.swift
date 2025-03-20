//
//  _VExpList2.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/8/25.
//

import SwiftUI

fileprivate struct _VExpList2: View {
	let items = ["Item 1", "Item 2", "Item 3"]

    var body: some View {
        List {
            ForEach(items, id: \.self) { item in
            	let isSecond = item == "Item 2"
                HStack {
                    Text(item)
						.border(.green)
                    
                    Spacer()
                    
                    // - second item will show row selection becasue
                    //   the automatic behavior is to merge the button action
					//   with the row's.  The other two change the button style
					//   explicitly and it ensures the button operates
					//   independently and there is no row selection.
					if isSecond {
						Button(action: {
							print("\(item) button tapped!")
						}) {
							Text("Tap Me")
								.padding(8)
								.background(Color.blue)
								.foregroundColor(.white)
								.cornerRadius(8)
						}
						.buttonStyle(.automatic)
					} else {
						Button(action: {
							print("\(item) button tapped!")
						}) {
							Text("Tap Me")
								.padding(8)
								.background(Color.blue)
								.foregroundColor(.white)
								.cornerRadius(8)
						}
						.buttonStyle(.borderless)
					}
                }
				.onTapGesture {
					// - this will only work if you tap on the text within the
					//   row and not the row itself.
					print("- tapped on text item \(item)")
				}
            }
        }
    }
}

#Preview {
    _VExpList2()
}
