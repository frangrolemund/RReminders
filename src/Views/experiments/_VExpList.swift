//
//  _VExpList.swift
//  RReminders
// 
//  Created on 3/1/25
//  Copyright © 2025 Francis Grolemund.  All rights reserved. 
//

import SwiftUI

// - the objective was to reproduce the layout of the summary screen in the Reminders app so that
//   I could have content at the top that will scroll with the list and get the styling and table behavior of
//   a grouped list.  The approach here is to put the random other content in the header of the list.

fileprivate struct _VExpList: View {
    var body: some View {
        List {
        	Section {
        	
        	} header: {
        		Text("Empty")
					.font(.title)
					.bold()
					.textCase(nil)
					.foregroundStyle(.primary)
        	}
        
        	Section {
				Text("alpha")
        		Text("beta")
        		Text("gamma")
        	} header: {
				VStack(spacing: 10) {
					HStack(spacing: 10) {
						Color.red
						Color.blue
					}
					.frame(height: 100)
					
					HStack(spacing: 10) {
						Color.green
						Color.purple
					}
					.frame(height: 100)
					.padding([.bottom])
					
					// - the styling here is nuanced and dictated in part by .textCase(nil).  Without it,
					//   the text will be auto-capitalized and the Color.primary will equate to the _primary color
					//   choice for section headers..._ which isn't what we're aiming for in this example.
					// - aside from the capitalization, if the .textCase modifier were omitted you could use an
					//   explicit color (Color.black) instead, but you wouldn't get the overall styling.
					HStack {
						Text("My Letters")
							.textCase(nil)
							.font(.title)
							.bold()
						Spacer()
					}
				}
				.foregroundStyle(.primary)
        	}
        }
		.listStyle(.insetGrouped)
    }
}

#Preview {
    _VExpList()
}
