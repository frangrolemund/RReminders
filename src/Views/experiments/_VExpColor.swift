//
//  _VExpColor.swift
//  RReminders
// 
//  Created on 3/1/25
//  Copyright © 2025 Francis Grolemund.  All rights reserved. 
//

import SwiftUI

fileprivate struct _VExpColor: View {
    var body: some View {
    	
		ZStack {
			// - notice the use of UIColor to get a broader selection of options that
			//   are fine-tuned for iOS.
			// - it would make sense to reference these from the asset catalog
			//   so that they can be customized per platform
			Color(uiColor: UIColor.quaternarySystemFill)
				.ignoresSafeArea()
		
			//	Color is greedy and will consume as much space as it has available.
			VStack(spacing: 0) {
				HStack(spacing: 0) {
					Color.green
					Color.blue
				}
				HStack(spacing: 0) {
					Color.orange
					Color.purple
				}
			}
		}
    }
}

#Preview {
    _VExpColor()
}
