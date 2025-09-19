//
//  Spinner.swift
//  News18AppleTV
//
//  Created by Mohan R on 25/10/24.
//

import SwiftUI

struct Spinner: View {
    enum SizeOption {
        case large
        case regular
        case mini

        var size: CGFloat {
            switch self {
            case .large:
                return 80
            case .regular:
                return 40
            case .mini:
                return 30
            }
        }

        var lineWidth: CGFloat {
            switch self {
            case .large:
                return 10
            case .regular:
                return 3
            case .mini:
                return 2
            }
        }
    }

    var size: SizeOption = .large
    @State private var isAnimating: Bool = false

    var body: some View {
        Circle()
            .trim(from: 0.2, to: 1.0)
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [.red]),
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                lineWidth: size.lineWidth
            )
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(isAnimating ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isAnimating)
            .frame(width: size.size, height: size.size)
            .onAppear {
                isAnimating = true
            }
            .onDisappear {
                isAnimating = false
            }
    }
}
struct HomeViewSpinner: View {
    @State private var isAnimating = false

    var body: some View {
        Circle()
            // draw 80% of the circle to get that “spinner” look
            .trim(from: 0.2, to: 1)
            .stroke(.red, lineWidth: 4)
            .frame(width: 40, height: 40)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .onAppear {
                // kick off the infinite rotation
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}
