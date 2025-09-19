//
//  TappableText.swift
//  News18AppleTV
//
//  Created by Mohan R on 25/10/24.
//
import SwiftUI

struct TappableText: View {
    enum Constants {
        static let focusedWidth: CGFloat = 165
        static let focusedHeight: CGFloat = 48
        static let cornerRadius: CGFloat = 6
        static let focusedBackgroundColor = Color(hex: "#A5A5A5").opacity(0.5)
        static let offsetX: CGFloat = (focusedWidth / 2) + 312
        static let offsetY: CGFloat = 40
        static let regular = UIFont(name: "Roboto-Regular", size: 24) ?? .systemFont(ofSize: 24)
    }

    let fullText: String
    let tappableText: String
    let fullTextColor: Color
    let fullTextFont: Font
    let tappableTextColor: Color
    let tappableTextFont: Font
    let action: () -> Void

    @FocusState private var isTextFocused: Bool
    @State private var tappableTextRect: CGRect = .zero

    var body: some View {
        ZStack {
            getFocusOverlay()

            Text(createAttributedString())
                .focusable()
                .focused($isTextFocused)
                .onTapGesture {
                    action()
                }
                .background(getBackgroundGeometry())
                .overlay(
                    Rectangle()
                        .frame(width: 154, height: 2)
                        .offset(x: Constants.offsetX, y: 57))
        }

    }

    private func getBackgroundGeometry() -> some View {
        GeometryReader { geometry in
            let nsString = NSString(string: fullText)
            if fullText.range(of: tappableText) != nil {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: Constants.regular
                ]
                let rect = nsString.boundingRect(
                    with: geometry.size,
                    options: .usesLineFragmentOrigin,
                    attributes: attributes,
                    context: nil
                )
                DispatchQueue.main.async {
                    tappableTextRect = rect
                }
            }
            return Color.clear
        }
    }

    private func getFocusOverlay() -> some View {
        Group {
            if isTextFocused {
                Rectangle()
                    .fill(Constants.focusedBackgroundColor)
                    .frame(width: Constants.focusedWidth, height: Constants.focusedHeight)
                    .cornerRadius(Constants.cornerRadius)
                    .offset(x: tappableTextRect.minX + Constants.offsetX, y: Constants.offsetY)
            }
        }
    }

    private func createAttributedString() -> AttributedString {
        var attributedString = AttributedString(fullText)
        if let tappableRange = attributedString.range(of: tappableText) {
            attributedString[tappableRange].foregroundColor = tappableTextColor
            attributedString[tappableRange].font = tappableTextFont
        }

        if let nonTappableRange = attributedString.range(
            of: fullText.replacingOccurrences(of: tappableText, with: "")
        ) {
            attributedString[nonTappableRange].foregroundColor = fullTextColor
            attributedString[nonTappableRange].font = fullTextFont
        }

        return attributedString
    }
}
