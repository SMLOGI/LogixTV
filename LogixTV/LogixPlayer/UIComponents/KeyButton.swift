//
//  KeyButton.swift
//  News18AppleTV
//
//  Created by Ayush ghadekar on 04/01/25.
//

import SwiftUI

enum Keyconstants {
    static let buttonwidth: CGFloat = 103
    static let buttonheight: CGFloat = 67
    static let cornerRadius: CGFloat = 10
}
    struct KeyButton: View {
        let key: String
        let isFocused: Bool
        let action: () -> Void
        var frame: CGSize?
        var body: some View {
            Button(action: action) {
                Group {
                    switch key {
                    case "space":
                        Image("space")
                    case "delete":
                        Image("delete")
                    default:
                        Text(key)
                    }
                }
                .font(.system(size: 28))
                .foregroundColor(.white)
                .frame(
                    width: frame?.width ?? Keyconstants.buttonwidth,
                    height: frame?.height ?? Keyconstants.buttonheight
                )
                .background(isFocused ? Color(.red) : Color(.gray))
                .overlay(
                    RoundedRectangle(cornerRadius: Keyconstants.cornerRadius)
                        .stroke(
                            isFocused ? Color.white : Color(.gray),
                            lineWidth: 4
                        )
                )
                .cornerRadius( Keyconstants.cornerRadius)
            }
            .buttonStyle(ClearButtonStyle())
        }
    struct ClearButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .contentShape(Rectangle())
        }
    }
}
