//
//  _VExpAnim.swift
//  RReminders
//
//  Created by Francis Grolemund on 4/21/25.
//

import SwiftUI

fileprivate struct _VExpAnim: View {
	@State private var isTop: Bool = true
	
    var body: some View {
		NavigationStack {
			VStack {
				if !isTop {
					Spacer()
				}
				HStack {
					NodeRect(color: .red)
					NodeRect(color: .orange)
					NodeRect(color: .green)
					NodeRect(color: .purple)
				}
				if isTop {
					Spacer()
				}
			}
			.frame(maxHeight: .infinity)
			.toolbar {
				ToolbarItem {
					Button("Smooth") {
						withAnimation(.smooth) {
							isTop.toggle()
						}
					}
				}
				
				ToolbarItem {
					Button("Snappy") {
						withAnimation(.snappy) {
							isTop.toggle()
						}
					}
				}
				
				ToolbarItem {
					Button("Bouncy") {
						withAnimation(.bouncy) {
							isTop.toggle()
						}
					}
				}
				
				ToolbarItem {
					Button("EaseOut") {
						withAnimation(.easeOut.speed(0.2)) {
							isTop.toggle()
						}
					}
				}

				ToolbarItem {
					Button("EaseInOut") {
						withAnimation(.easeInOut.speed(0.2)) {
							isTop.toggle()
						}
					}
				}
			}
		}
    }
}

fileprivate struct NodeRect: View {
	let color: Color
	
	var body: some View {
		Rectangle()
			.frame(width: 75, height: 75)
			.foregroundStyle(color)
	}
}

#Preview {
    _VExpAnim()
}
