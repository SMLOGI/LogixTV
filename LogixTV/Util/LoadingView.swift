//
//  LoadingView.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 07/10/25.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
             CircularProgress()
            // RotatingSquare()
          //   PulsingDots()
           //  ScalingBars()
           //  SpinningArc()
           // ExpandingRings()
            // TextTypingIndicator()
            // ShimmerEffect()
            // HeartbeatLoader()
             //SpiralLoader()
        }
        .padding()
    }
}

// 1. Classic Circular Progress
struct CircularProgress: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
    }
}

// 2. Rotating Square
struct RotatingSquare: View {
    @State private var rotate = false
    var body: some View {
        Rectangle()
            .frame(width: 40, height: 40)
            .rotationEffect(.degrees(rotate ? 360 : 0))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
            .onAppear { rotate.toggle() }
    }
}

// 3. Pulsing Dots
struct PulsingDots: View {
    @State private var scale = false
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<4) { i in
                Circle()
                    .frame(width: 15, height: 15)
                    .scaleEffect(scale ? 1 : 0.5)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(i) * 0.2),
                        value: scale
                    )
            }
        }
        .frame(width: 96, height: 50)
        .onAppear {
            scale.toggle()
        }
    }
}

// 4. Scaling Bars
struct ScalingBars: View {
    @State private var scale = false
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<5) { i in
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 8, height: 30)
                    .scaleEffect(scale ? 1 : 0.5, anchor: .bottom)
                    .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.1))
            }
        }
        .onAppear { scale.toggle() }
    }
}

// 5. Spinning Arc
struct SpinningArc: View {
    @State private var rotate = false
    var body: some View {
        Circle()
            .trim(from: 0.2, to: 1)
            .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
            .frame(width: 40, height: 40)
            .rotationEffect(.degrees(rotate ? 360 : 0))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
            .onAppear { rotate.toggle() }
    }
}

// 6. Expanding Rings
struct ExpandingRings: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                Circle()
                    .stroke(lineWidth: 2)
                    .scaleEffect(animate ? 2 : 0)
                    .opacity(animate ? 0 : 1)
                    .animation(Animation.easeOut(duration: 1.5).repeatForever().delay(Double(i) * 0.5))
            }
        }
        .frame(width: 40, height: 40)
        .onAppear { animate.toggle() }
    }
}

// 7. Text Typing Indicator
struct TextTypingIndicator: View {
    @State private var opacity = false
    var body: some View {
        HStack {
            Text("Loading")
            ForEach(0..<3) { i in
                Circle()
                    .frame(width: 5, height: 5)
                    .opacity(opacity ? 1 : 0.3)
                    .animation(Animation.easeInOut(duration: 0.6).repeatForever().delay(Double(i) * 0.2))
            }
        }
        .onAppear { opacity.toggle() }
    }
}

// 8. Shimmer Effect
struct ShimmerEffect: View {
    @State private var move = false
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .frame(width: 100, height: 10)
            .overlay(
                LinearGradient(gradient: Gradient(colors: [.clear, .white.opacity(0.8), .clear]), startPoint: .leading, endPoint: .trailing)
                    .frame(width: 80)
                    .offset(x: move ? 50 : -50)
                    .animation(Animation.linear(duration: 1.5).repeatForever())
            )
            .onAppear { move.toggle() }
    }
}

// 9. Heartbeat Loader
struct HeartbeatLoader: View {
    @State private var scale = false
    var body: some View {
        Circle()
            .frame(width: 30, height: 30)
            .scaleEffect(scale ? 1.2 : 1)
            .animation(Animation.easeInOut(duration: 0.6).repeatForever())
            .onAppear { scale.toggle() }
    }
}

// 10. Spiral Loader
struct SpiralLoader: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            ForEach(0..<12) { i in
                Circle()
                    .frame(width: 5, height: 5)
                    .offset(y: animate ? 20 : 0)
                    .rotationEffect(.degrees(Double(i) * 30))
                    .animation(Animation.linear(duration: 1).repeatForever().delay(Double(i) * 0.1))
            }
        }
        .onAppear { animate.toggle() }
    }
}

