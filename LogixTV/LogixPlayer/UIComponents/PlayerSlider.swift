//
//  PlayerSlider.swift
//  News18AppleTV
//
//  Created by Mohan Sivaram Ramasamy on 06/11/24.
//
import SwiftUI
import AVFoundation

struct PlayerSlider: View {
    @EnvironmentObject var playbackViewModel: PlaybackViewModel
    @State private var sliderValue: Double = 0.0
    @State private var totalDuration: Double = 0.0
    @State private var currentTime: Double = 0.0
    @State private var isSeeking: Bool = false
    @State private var lastSeekTime: Date = Date()
    @FocusState private var isFocused: Bool
    let action: () -> Void
    private let sliderWidth: CGFloat = 1620
    private let sliderHeight: CGFloat = 10
    private let markerWidth: CGFloat = 10
    private let horizontalPadding: CGFloat = 60
    private let stackSpacing: CGFloat = 18
    @State private var adMarkers: [CGFloat] = []

    var body: some View {
        HStack(spacing: stackSpacing) {
            /*
            Text(CMTime(seconds: currentTime, preferredTimescale: 1).durationText)
                .foregroundColor(.white)
                .font(.system(size: 28))
                .frame(width: 72, height: 33, alignment: .leading)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .allowsTightening(true)
             */

            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(hex: "#A0A0A0").opacity(1))
                    .frame(width: sliderWidth, height: sliderHeight)
                    .cornerRadius(5)

                Rectangle()
                    .fill(Color(hex: "#EE1D24"))
                    .frame(width: max(0, min(CGFloat(sliderValue) * sliderWidth, sliderWidth)),
                           height: sliderHeight)
                    .cornerRadius(sliderHeight / 2)

                ForEach(Array(adMarkers.enumerated()), id: \.offset) { index, position in
                    Rectangle()
                        .fill(Color.yellow)
                        .frame(width: markerWidth, height: sliderHeight)
                        .clipShape(
                            RoundedCornersShape(
                                corners: index == 0 ? [.topLeft, .bottomLeft] : (index == adMarkers.count - 1 ? [.topRight, .bottomRight] : []),
                                radius: sliderHeight / 2
                            )
                        )
                        .offset(x: position - 1)
                }

                if isFocused {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 18, height: 18)
                        .offset(x: CGFloat(sliderValue) * sliderWidth - 8)
                }
            }
            .focusable(true)
            .focused($isFocused)
            .onCompatibleChange(of: isFocused) { _, focused in
                if focused {
                    if let progress = playbackViewModel.progress {
                        sliderValue = progress.currentDuration / progress.totalDuration
                    }
                }
            }
            .onMoveCommand { direction in
                guard isFocused else { return }

                switch direction {
                case .left:
                    isSeeking = true
                    lastSeekTime = Date()
                    sliderValue = max(0, sliderValue - (10.0 / totalDuration))
                    updatePlaybackPosition()
                    action()
                case .right:
                    isSeeking = true
                    lastSeekTime = Date()
                    sliderValue = min(1, sliderValue + (10.0 / totalDuration))
                    updatePlaybackPosition()
                    action()
                default:
                    break
                }
            }
            .onChange(of: isFocused) { newValue in
                if !newValue {
                    isSeeking = false
                }
            }

            Text(CMTime(seconds: totalDuration, preferredTimescale: 1).durationText)
                .foregroundColor(.white)
                .font(.robotoBold(size: 28))
                .frame(width: 72, height: 33, alignment: .trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .allowsTightening(true)
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.bottom, 91)
        .onReceive(playbackViewModel.$progress) { progress in
            guard let progress = progress else { return }
            totalDuration = progress.totalDuration
            if isSeeking {
                let timeSinceLastSeek = Date().timeIntervalSince(lastSeekTime)
                if timeSinceLastSeek > 0.5 { 
                    isSeeking = false
                }
            }

            if !isSeeking {
                currentTime = progress.currentDuration
                if totalDuration > 0 {
                    sliderValue = currentTime / totalDuration
                }
            }
        }
        .onReceive(playbackViewModel.$adPositions) { newValue in
            guard !newValue.isEmpty else { return }
            updateAdMarker(newValue)
        }
    }

    private func updatePlaybackPosition() {
        if let progress = playbackViewModel.progress {
            let seekPosition = sliderValue * progress.totalDuration
            playbackViewModel.seekToPosition(value: Float(seekPosition))
            currentTime = seekPosition
        }
    }

    private func updateAdMarker(_ adPositions: [Double]) {
        adMarkers = adPositions.compactMap { adPosition in
            let position = adPosition == -1 ? (sliderWidth - markerWidth)
            : CGFloat(adPosition / totalDuration) * sliderWidth
            return position.isNaN ? 0 : position
        }
    }
}

struct RoundedCornersShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
