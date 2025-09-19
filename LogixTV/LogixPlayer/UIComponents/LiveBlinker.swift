//
//  LiveBlinker.swift
//  News18AppleTV
//
//  Created by Mohan Sivaram Ramasamy on 13/11/24.
//
import SwiftUI

struct LiveBlinker: View {
    @State private var isVisible = true

    var body: some View {
        Circle()
            .fill(Color.red)
            .frame(width: 14, height: 14)
            .opacity(isVisible ? 1 : 0)  // Toggle opacity to create the blink
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 0.7)
                        .repeatForever(autoreverses: true)
                ) {
                    isVisible.toggle()
                }
            }
    }
}
