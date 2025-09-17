//
//  PlaybackControlsView.swift
//  VideoPlayerSwiftUI
//
//  Created by Pradip on 15/05/25.
//

import SwiftUI

struct PlaybackControlsView: View {
    @Binding var isPlaying: Bool
    var onPlayPause: ((Bool) -> Void)? = nil
    var onSeekForward: (() -> Void)? = nil
    var onSeekBackward: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 40) {
            // Backward 10 seconds
            Button(action: {
                onSeekBackward?()
            }) {
                Image(systemName: "backward.fill")
                    .resizable()
                    .foregroundColor(.white)
                    .frame(width: 40, height: 25)
            }

            // Play / Pause
            Button(action: {
                isPlaying.toggle()
                onPlayPause?(isPlaying)
            }) {
                Image(isPlaying ? "pauseIcon" : "playIcon")
                    .resizable()
                    .frame(width: 60, height: 60)
            }

            // Forward 10 seconds
            Button(action: {
                onSeekForward?()
            }) {
                Image(systemName: "forward.fill")
                    .resizable()
                    .foregroundColor(.white)
                    .frame(width: 40, height: 25)
            }

        }
        .padding()
    }
}
