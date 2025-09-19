//
//  FullScreenLoader.swift
//  News18AppleTV
//
//  Created by Mohan R on 24/10/24.
//

import SwiftUI

struct FullScreenLoaderModifier: ViewModifier {
    @Binding var isLoading: Bool

    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading)

            if isLoading {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .background(Color.black)

                VStack {
                    Spinner(size: .large)
                }
            }
        }
    }
}

extension View {
    func fullScreenLoader(isLoading: Binding<Bool>) -> some View {
        self.modifier(FullScreenLoaderModifier(isLoading: isLoading))
    }
}
