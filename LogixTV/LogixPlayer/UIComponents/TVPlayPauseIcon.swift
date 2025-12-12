//
//  TVPlayPauseIcon.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 08/12/25.
//

import SwiftUI

struct TVPlayPauseIcon: View {
    let icon: String
        let size: CGFloat
        let cornerRadius: CGFloat
        let action: () -> Void

        @FocusState private var isFocused: Bool

        var body: some View {
            Image(systemName: icon)
                .font(.system(size: size, weight:  isFocused ? .bold: .regular))
                .frame(width: size * 1.8, height: size * 1.8)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.white, lineWidth: isFocused ? 10 : 6)   // thin border
                )
                .cornerRadius(cornerRadius)
                .focusable(true)
                .focused($isFocused)
                .scaleEffect(isFocused ? 1.12 : 1.0)                    // tvOS zoom effect
                .animation(.easeInOut(duration: 0.15), value: isFocused)
                .onTapGesture { action() }
        }
}

