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
    @FocusState.Binding var focusedSection: LivePlayerControlsView.ControlFocus?
    @Binding var isUserSeeking: Bool
    
    @State private var isFocused: Bool = false
    
    var body: some View {
        HStack(spacing: 15.0) {
            Text(formatTime(currentTime))
            showProgressBar()
            Text(formatTime(totalTime))
        }
        .font(.caption2)
        .foregroundColor(.white.opacity(0.7))
    }
    
    private func showProgressBar() -> some View {
        ZStack {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: isFocused ? 12 : 10)

                    Capsule()
                        .fill(focusedSection == .progressBar ? Color.green : Color.white)
                        .frame(
                            width: proxy.size.width * CGFloat(currentTime / max(totalTime, 0.1)),
                            height: isFocused ? 12 : 10
                        )
                }
                .animation(.easeInOut(duration: 0.2), value: isFocused)
            }
            .frame(height: 12)   // only height is constrained
        }
        .fixedSize(horizontal: false, vertical: true)
        .focusable(true)
        .focused($focusedSection, equals: .progressBar)
        //.onMoveCommand(perform: handleMove)
        // *** IMP : To remove above comment so that user can fast forward video
        // Note: This feature conflicts when user focus chnage from progress bar ro bottom tab button due to,  isUserSeeking = true
    }
    
    private func handleMove(_ direction: MoveCommandDirection) {
        print("ProgressSliderView handleMove direction =\(direction)")
        guard !isUserSeeking else { return }
        isUserSeeking = true
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
