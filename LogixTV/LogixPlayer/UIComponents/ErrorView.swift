//
//  FullscreenError.swift
//  News18AppleTV
//
//  Created by Mohan R on 25/10/24.
//

import SwiftUI

struct ErrorInfo {
    let title: String
    let message: String
}

struct ErrorViewModifier: ViewModifier {
    @Binding var errorInfo: ErrorInfo?
    let onRetry: (() -> Void)?

    func body(content: Content) -> some View {
        ZStack {
            content
            if let errorInfo = errorInfo {
                ErrorView(errorInfo: errorInfo, buttonAction: onRetry)
                    .transition(.opacity)
                    .focusable()
            }
        }
    }
}

struct ErrorView: View {
    let errorInfo: ErrorInfo
    let buttonAction: (() -> Void)?
    @FocusState private var isButtonFocused: Bool

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                Image(systemName: "exclamationmark.triangle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.red)
                Text(errorInfo.title)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                Text(errorInfo.message)
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                if let buttonAction = buttonAction {
                    RoundedRectButton(title: "OK") {
                        buttonAction()
                    }
                    .focused($isButtonFocused)
                    .onAppear {
                        isButtonFocused = true
                    }
                    .padding(.top, 20)
                }
                Spacer()
            }
            .padding()
        }
        .focusSection()
    }
}

extension View {
    func fullscreenError(errorInfo: Binding<ErrorInfo?>, onRetry: (() -> Void)? = nil) -> some View {
        self.modifier(ErrorViewModifier(errorInfo: errorInfo, onRetry: onRetry))
    }
}
