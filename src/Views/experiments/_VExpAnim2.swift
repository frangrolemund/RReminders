//
//  _VExpAnim2.swift
//  RReminders
//
//  Created by Francis Grolemund on 4/23/25.
//

import SwiftUI

fileprivate struct _VExpAnim2: View {
	@State private var isToolbarVisible = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content
            Color.gray.opacity(0.1)
                .ignoresSafeArea()
            
            // Toolbar
            if isToolbarVisible {
                ToolbarView()
                    .transition(.move(edge: .bottom)) // Slide from bottom
            }
        }
        .animation(.easeInOut, value: isToolbarVisible) // Animate transition
        .onTapGesture {
            isToolbarVisible.toggle() // Toggle toolbar visibility
        }
    }
}

#Preview {
    _VExpAnim2()
}


fileprivate struct ToolbarView: View {
    var body: some View {
        HStack {
            Spacer()
            Text("Toolbar")
            Spacer()
        }
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
    }
}
