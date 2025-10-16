//
//  ProgressSliderView.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 16/10/25.
//

import SwiftUI

struct ProgressSliderView: View {
    @Binding var currentTime: Double
    var totalTime: Double
    var onSeek: (Double) -> Void
    @FocusState.Binding var focusedSection: LivePlayerControlsView.FocusSection?
    
    @State private var isFocused: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: isFocused ? 12 : 10)
                
                Capsule()
                    .fill(focusedSection == .progressBar ? Color.green : Color.white)
                    .frame(width: progressWidth, height: isFocused ? 12 : 10)
            }
            .animation(.easeInOut(duration: 0.2), value: isFocused)
            .focusable(true)
            .focused($focusedSection, equals: .progressBar)
            .onMoveCommand(perform: handleMove)
            
            HStack {
                Text(formatTime(currentTime))
                Spacer()
                Text(formatTime(totalTime))
            }
            .font(.caption2)
            .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 80)
    }
    
    private var progressWidth: CGFloat {
        CGFloat(currentTime / max(totalTime, 1)) * 800 // dynamic width
    }
    
    private func handleMove(_ direction: MoveCommandDirection) {
        let step = 10.0 // 10-second skip
        if direction == .left {
            currentTime = max(0, currentTime - step)
            onSeek(currentTime)
        } else if direction == .right {
            currentTime = min(totalTime, currentTime + step)
            onSeek(currentTime)
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite else { return "00:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
