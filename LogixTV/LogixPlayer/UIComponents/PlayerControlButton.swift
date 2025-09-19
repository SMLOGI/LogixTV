//
//  PlayerControlButton.swift
//  News18AppleTV
//
//  Created by Mohan Sivaram Ramasamy on 06/11/24.
//

import SwiftUI

struct PlayerControlButton: View {
    let imageName: String
    let focusedImageName: String
    let buttonSize: CGFloat?
    let action: () -> Void

    @FocusState private var isFocused: Bool

    private enum Layout {
        static let defaultButtonSize: CGFloat = 124
        static let cornerRadius: CGFloat = 62
        static let focusedScale: CGFloat = 1.2
    }

    init(imageName: String,focusedImageName: String, buttonSize: CGFloat? = nil, action: @escaping () -> Void) {
        self.imageName = imageName
        self.buttonSize = buttonSize
        self.action = action
        self.focusedImageName = focusedImageName
    }

    var body: some View {
        Image(isFocused ? focusedImageName : imageName)
            .resizable()
            .scaledToFit()
            .frame(width: buttonSize ?? Layout.defaultButtonSize, height: buttonSize ?? Layout.defaultButtonSize)
            .background(
                isFocused
                ? Color.gray.opacity(1)
                : Color.clear
            )
            .cornerRadius(Layout.cornerRadius)
            .animation(.easeInOut, value: isFocused)
            .focusable(true)
            .focused($isFocused)
            .onTapGesture {
                action()
            }
    }
}
