//
//  RoundedRectButton.swift
//  News18AppleTV
//
//  Created by Mohan R on 18/10/24.
//

import Foundation
import SwiftUI

struct RoundedRectButton: View {
    let title: String
    let action: () -> Void

    @FocusState private var isFocused: Bool

    private enum Layout {
        static let textPadding = EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        static let borderWidth: CGFloat = 1
        static let focusedBorderWidth: CGFloat = 4
        static let cornerRadius: CGFloat = 25
        static let buttonWidth: CGFloat = 154
        static let buttonHeight: CGFloat = 40
    }

    private enum Colors {
        static let unfocusedTextColor = Color(hex: "#A7A7A7")
        static let focusedTextColor = Color.white
        static let backgroundColor = Color.black
        static let focusedBackgroundColor = Color(hex: "#EE1D24")
        static let borderColor = Color(hex: "#575757")
        static let focusedBorderColor = Color.white
    }

    var body: some View {
        Text(title)
            .font(.custom(isFocused ? "Roboto-Bold" : "Roboto-Regular", size: 18))
            .padding(Layout.textPadding)
            .foregroundColor(isFocused ? Colors.focusedTextColor : Colors.unfocusedTextColor)
            .frame(width: Layout.buttonWidth, height: Layout.buttonHeight)
            .background(isFocused ? Colors.focusedBackgroundColor : Colors.backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: Layout.cornerRadius)
                    .stroke(isFocused ? Colors.focusedBorderColor : Colors.borderColor,
                            lineWidth: isFocused ? Layout.focusedBorderWidth : Layout.borderWidth)
            )
            .cornerRadius(Layout.cornerRadius)
            .focusable(true)
            .focused($isFocused)
            .onTapGesture {
                action()
            }
    }
}

struct HeroWatchNowButton: View {
    let title: String
    let isFocused:Bool
        
    private enum Layout {
        static let textPadding = EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        static let borderWidth: CGFloat = 1
        static let focusedBorderWidth: CGFloat = 4
        static let cornerRadius: CGFloat = 25
        static let buttonWidth: CGFloat = 154
        static let buttonHeight: CGFloat = 40
    }
    
    private enum Colors {
        static let unfocusedTextColor = Color(hex: "#A7A7A7")
        static let focusedTextColor = Color.white
        static let backgroundColor = Color.black
        static let focusedBackgroundColor = Color(hex: "#EE1D24")
        static let borderColor = Color(hex: "#575757")
        static let focusedBorderColor = Color.white
    }
    
    var body: some View {
        Text(title)
            .font(.custom(isFocused ? "Roboto-Bold" : "Roboto-Regular", size: 18))
            .padding(Layout.textPadding)
            .foregroundColor(isFocused ? Colors.focusedTextColor : Colors.unfocusedTextColor)
            .frame(width: Layout.buttonWidth, height: Layout.buttonHeight)
            .background(isFocused ? Colors.focusedBackgroundColor : Colors.backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: Layout.cornerRadius)
                    .stroke(isFocused ? Colors.focusedBorderColor : Colors.borderColor,
                            lineWidth: isFocused ? Layout.focusedBorderWidth : Layout.borderWidth)
            )
            .cornerRadius(Layout.cornerRadius)
    }
}

struct ExitButton: View {
    let title: String
    let action: () -> Void

    @FocusState private var isFocused: Bool

    private enum Layout {
        static let textPadding = EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        static let borderWidth: CGFloat = 1
        static let focusedBorderWidth: CGFloat = 4
        static let cornerRadius: CGFloat = 25
        static let buttonWidth: CGFloat = 120
        static let buttonHeight: CGFloat = 50
    }

    private enum Colors {
        static let unfocusedTextColor = Color(hex: "#A7A7A7")
        static let focusedTextColor = Color.white
        static let backgroundColor = Color.black
        static let focusedBackgroundColor = Color(hex: "#EE1D24")
        static let borderColor = Color(hex: "#575757")
        static let focusedBorderColor = Color.white
    }

    var body: some View {
        Text(title)
            .font(.custom(isFocused ? "Roboto-Bold" : "Roboto-Regular", size: 18))
            .padding(Layout.textPadding)
            .foregroundColor(isFocused ? Colors.focusedTextColor : Colors.unfocusedTextColor)
            .frame(width: Layout.buttonWidth, height: Layout.buttonHeight)
            .background(isFocused ? Colors.focusedBackgroundColor : Colors.backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: Layout.cornerRadius)
                    .stroke(isFocused ? Colors.focusedBorderColor : Colors.borderColor,
                            lineWidth: isFocused ? Layout.focusedBorderWidth : Layout.borderWidth)
            )
            .cornerRadius(Layout.cornerRadius)
            .focusable(true)
            .focused($isFocused)
            .onTapGesture {
                action()
            }
    }
}

struct TrendingSearchButton: View {
    let title: String
    let action: () -> Void

    @FocusState private var isFocused: Bool

    private enum Layout {
        static let textPadding = EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30)
        static let borderWidth: CGFloat = 2
        static let focusedBorderWidth: CGFloat = 4
        static let cornerRadius: CGFloat = 30
        static let buttonHeight: CGFloat = 50
    }

    private enum Colors {
        static let unfocusedTextColor = Color(hex: "#A7A7A7")
        static let focusedTextColor = Color.white
        static let backgroundColor = Color(hex: "#191919")
        static let focusedBackgroundColor = Color(hex: "#EE1D24")
        static let borderColor = Color(hex: "#575757")
        static let focusedBorderColor = Color.white
    }

    var body: some View {
        Text(title)
            .font(.custom(isFocused ? "Roboto-Bold" : "Roboto-Bold", size: 18))
            .padding(Layout.textPadding)
            .foregroundColor(isFocused ? Colors.focusedTextColor : Colors.focusedTextColor)
            .frame(maxWidth: .infinity)
            .frame(height: Layout.buttonHeight)
            .background(isFocused ? Colors.focusedBackgroundColor : Colors.backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: Layout.cornerRadius)
                    .stroke(isFocused ? Colors.focusedBorderColor : Colors.borderColor,
                            lineWidth: isFocused ? Layout.focusedBorderWidth : Layout.borderWidth)
            )
            .cornerRadius(Layout.cornerRadius)
            .focusable(true)
            .focused($isFocused)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .onTapGesture {
                action()
            }
    }
}
struct SettingsButton: View {
    let title: String
    let onFocusChange: () -> Void
    let isSelected: Bool  // Add this property
    var textPaddingTrailing: CGFloat = 10
    var textPaddingLeading: CGFloat = 10
    var withoutfocused: Color = Color.gray
    var whiteColor: Color = .white
    var borderWidth: CGFloat = 1
    var borderColor: Color = Color(hex: "#575757")
    var cornerRadius: CGFloat = 30

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Text(title.localized)
                .font(isFocused || isSelected ? .custom("Roboto-Bold", size: 22) : .custom("Roboto-Regular", size: 22))
                .foregroundColor(isFocused || isSelected ? whiteColor : withoutfocused)
                .padding(.trailing, textPaddingTrailing)
        }
        .frame(width: 200, height: 60)
        .background(isFocused || isSelected ? Color(hex: "#EE1D24") : Color(hex: "#191919"))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(isFocused || isSelected ? Color.white : Color.clear, lineWidth: isFocused || isSelected ? 4 : 0)
        )
        .cornerRadius(cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(borderColor, lineWidth: isFocused || isSelected ? 0 : borderWidth)
        )
        .focusable(true)
        .focused($isFocused)
        .onCompatibleChange(of: isFocused) { _, focused in
            if focused {
                onFocusChange()
            }
        }
    }
}
// MARK: - Retry buttons for Error views
struct RetryButton: View {
    let title: String
    let action: () -> Void
    
    @FocusState private var isFocused: Bool
    
    private enum Layout {
        static let textPadding = EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        static let cornerRadius: CGFloat = 25
        static let buttonWidth: CGFloat = 140
        static let buttonHeight: CGFloat = 50
    }
    
    private enum Colors {
        static let textColor = Color.white
        static let backgroundColor = Color(hex: "#EE1D24")
        static let borderColor = Color.white
    }
    
    var body: some View {
        Text(title)
            .font(.custom("Roboto-Bold", size: 18))
            .padding(Layout.textPadding)
            .foregroundColor(Colors.textColor)
            .frame(width: Layout.buttonWidth, height: Layout.buttonHeight)
            .background(Colors.backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: Layout.cornerRadius)
                    .stroke(Colors.borderColor, lineWidth: 4)
            )
            .cornerRadius(Layout.cornerRadius)
            .focusable(true)
            .focused($isFocused)
            .onAppear {
                isFocused = true
            }
            .onTapGesture {
                action()
            }
    }
}
struct SelectTracksButtons: View {
    let title: String
    let action: () -> Void

    @FocusState private var isFocused: Bool

    private enum Layout {
        static let textPadding = EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        static let borderWidth: CGFloat = 1
        static let focusedBorderWidth: CGFloat = 4
        static let cornerRadius: CGFloat = 25
        static let buttonWidth: CGFloat = 148
        static let buttonHeight: CGFloat = 50
    }

    private enum Colors {
        static let unfocusedTextColor = Color(hex: "#A7A7A7")
        static let focusedTextColor = Color.white
        static let backgroundColor = Color.black
        static let focusedBackgroundColor = Color(hex: "#EE1D24")
        static let borderColor = Color(hex: "#575757")
        static let focusedBorderColor = Color.white
    }

    var body: some View {
        Text(title)
            .font(.custom(isFocused ? "Roboto-Bold" : "Roboto-Regular", size: 18))
            .padding(Layout.textPadding)
            .foregroundColor(isFocused ? Colors.focusedTextColor : Colors.unfocusedTextColor)
            .frame(width: Layout.buttonWidth, height: Layout.buttonHeight)
            .background(isFocused ? Colors.focusedBackgroundColor : Colors.backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: Layout.cornerRadius)
                    .stroke(isFocused ? Colors.focusedBorderColor : Colors.borderColor,
                            lineWidth: isFocused ? Layout.focusedBorderWidth : Layout.borderWidth)
            )
            .cornerRadius(Layout.cornerRadius)
            .focusable(true)
            .focused($isFocused)
            .onTapGesture {
                action()
            }
    }
}
struct WatchAgainButton: View {
    let title: String
    let action: () -> Void

    @FocusState private var isFocused: Bool

    private enum Layout {
        static let textPadding = EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        static let borderWidth: CGFloat = 3
        static let focusedBorderWidth: CGFloat = 4
        static let cornerRadius: CGFloat = 35
        static let buttonWidth: CGFloat = 234
        static let buttonHeight: CGFloat = 70
    }

    private enum Colors {
        static let unfocusedTextColor = Color(hex: "#A7A7A7")
        static let focusedTextColor = Color.white
        static let backgroundColor = Color.black
        static let focusedBackgroundColor = Color(hex: "#EE1D24")
        static let borderColor = Color(hex: "#575757")
        static let focusedBorderColor = Color.white
    }

    var body: some View {
        HStack(spacing: 6) {
            Image("watchagain")
            Text(title)
                .font(.custom(isFocused ? "Roboto-Bold" : "Roboto-Regular", size: 20))
                .padding(Layout.textPadding)
                .foregroundColor(isFocused ? Colors.focusedTextColor : Colors.unfocusedTextColor)
                
        }
        .frame(width: Layout.buttonWidth, height: Layout.buttonHeight)
        .background(isFocused ? Colors.focusedBackgroundColor : Colors.backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: Layout.cornerRadius)
                .stroke(isFocused ? Colors.focusedBorderColor : Colors.borderColor,
                        lineWidth: isFocused ? Layout.focusedBorderWidth : Layout.borderWidth)
        )
        .cornerRadius(Layout.cornerRadius)
        .focusable(true)
        .focused($isFocused)
        .onTapGesture {
            action()
        }
    }
}
