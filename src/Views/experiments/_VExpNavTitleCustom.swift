//
//  _VExpNavTitleCustom.swift
//  RReminders
//
//  Created by Francis Grolemund on 5/13/25.
//

import SwiftUI
import UIKit

fileprivate let titleText = "Styled Title"

// - experiements around creating a styled navigation title that works like
//   a standard one that merges into the navigation (tool) bar.
fileprivate struct _VExpNavTitleCustom: View {
	@State private var isEmbedded: Bool = false
	@State private var topInset: CGFloat = 0
	
    var body: some View {
		GeometryReader { proxy in
			NavigationStack {
				List {
					Text(titleText)
						.font(.largeTitle)
						.bold()
						.italic()
						.foregroundStyle(Color.green)
						.selectionDisabled()
						.onGeometryChange(for: Bool.self) { proxy in
							let f = proxy.frame(in: .global)
							print("EXP: min-y offset \(f.minY), compared to \(topInset)")
							return f.minY < topInset
							
						} action: { newValue in
							withAnimation(.easeInOut(duration: 0.2)) {
								isEmbedded = newValue
							}
						}
						.listRowSeparator(.hidden)
						.visible(!isEmbedded)
					
					ForEach(0..<20) { i in
						Text("Item \(i)")
					}
				}
				.listStyle(.plain)
				.toolbar {
					Text("Action")
						.fontWeight(.medium)
						.foregroundStyle(.tint)
				}
				.navigationBarTitleDisplayMode(.inline)
				.navigationTitle(isEmbedded ? titleText: "")
				.onAppear {
					topInset = proxy.safeAreaInsets.top
					print("EXP: top is \(topInset)")
				}
			}
		}
    }
}

#Preview {
    _VExpNavTitleCustom()
}
