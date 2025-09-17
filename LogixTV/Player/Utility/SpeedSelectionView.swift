//
//  SpeedSelectionView.swift
//  VideoPlayerSwiftUI
//
//  Created by Pradip on 29/05/25.
//

import Foundation
import SwiftUI
import AVKit

struct PlaybackSpeedOption: Identifiable {
    let id = UUID()
    let rate: Float? // `nil` for Automatic (defaults to 1.0)
    let labelString: String?
}

struct SpeedSelectionView: View {
    @ObservedObject var controller: VideoPlayerController
    @Binding var showSpeedSelector: Bool
    
    let playbackSpeeds: [PlaybackSpeedOption] = [
        PlaybackSpeedOption(rate: 0.5, labelString: "0.5x"),
        PlaybackSpeedOption(rate: 0.75, labelString: "0.75x"),
        PlaybackSpeedOption(rate: 1.0, labelString: "Normal"),
        PlaybackSpeedOption(rate: 1.5, labelString: "1.5x"),
        PlaybackSpeedOption(rate: 2.0, labelString: "2x")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(playbackSpeeds) { speedOption in
                VStack(spacing: 0) {
                    HStack {
                        Text(speedOption.labelString ?? "")
                            .padding(.horizontal, 10)
                        Spacer()
                        Image(systemName: "checkmark")
                            .foregroundColor(controller.currentSpeed == (speedOption.rate ?? 1.0) ? .green : .clear)
                            .padding(.trailing, 10)
                    }
                    .frame(height: 35)
                    .contentShape(Rectangle()) // Ensures full row is tappable
                    .onTapGesture {
                        controller.setPlaybackSpeed(to: speedOption.rate ?? 1.0)
                        showSpeedSelector = false
                    }
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}
