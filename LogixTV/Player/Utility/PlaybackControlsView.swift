//
//  PlaybackControlsView.swift
//  VideoPlayerSwiftUI
//
//  Created by Pradip on 15/05/25.
//

import SwiftUI

enum ButtonType: Hashable {
        case backward, playPause, forward
    }


struct PlaybackControlsView: View {
    @Binding var isPlaying: Bool
    var onPlayPause: ((Bool) -> Void)? = nil
    var onSeekForward: (() -> Void)? = nil
    var onSeekBackward: (() -> Void)? = nil
    @FocusState private var focusedButton: ButtonType?
    
    var body: some View {
        HStack(spacing: 40) {
            // Backward 10 seconds
            Button(action: {
                onSeekBackward?()
            }) {
                Image(systemName: "backward.fill")
                    .resizable()
                    .foregroundColor(.white)
                    .frame(width: 60, height: 40)
            }
            .focused($focusedButton, equals: .backward)

            // Play / Pause
            Button(action: {
                isPlaying.toggle()
                onPlayPause?(isPlaying)
            }) {
                Image(isPlaying ? "pauseIcon" : "playIcon")
                    .resizable()
                    .frame(width: 100, height: 100)
            }
            .focused($focusedButton, equals: .playPause)

            // Forward 10 seconds
            Button(action: {
                onSeekForward?()
            }) {
                Image(systemName: "forward.fill")
                    .resizable()
                    .foregroundColor(.white)
                    .frame(width: 60, height: 40)
            }
            .focused($focusedButton, equals: .forward)


        }
        .padding()
        .focusSection()
    }
}
