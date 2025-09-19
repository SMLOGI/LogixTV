//
//  CheckBox.swift
//  News18AppleTV
//
//  Created by Mohan R on 17/10/24.
//
import SwiftUI

struct CheckBox: View {
    @Binding var checked: Bool
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(checked ? "checkbox_selected" : "checkbox")
                .resizable()
                .frame(width: 48, height: 48)
        }
        .frame(width: 48, height: 48)
        .background(isFocused ? .white.opacity(0.3) : .clear)
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(.clear, lineWidth: isFocused ? 0 : 2)
        )
        .focusable()
        .focused($isFocused)
        .onTapGesture {
            checked.toggle()
        }
    }
}
