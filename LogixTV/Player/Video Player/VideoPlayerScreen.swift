//
//  VideoPlayerScreen.swift
//  VideoPlayerSwiftUI
//
//  Created by Pradip on 15/05/25.
//

import SwiftUI

struct VideoPlayerScreen: View {
    @StateObject private var viewModel = VideoPlayerViewModel()
    let videoURL: URL
    let videoTitle: String
    @State private var isPlaying = true
    @StateObject private var controller = VideoPlayerController()
    @State private var isPlaybackVisible = true
    @State private var captionsEnabled = false
    @State private var showSettings = false
    @State private var showBitrate = false
    @State private var showSpeedSelector = false

    var body: some View {
        ZStack {
                SwiftUIVideoPlayer(videoURL: videoURL, controller: controller)
                    .edgesIgnoringSafeArea(.all)

                // Top Overlay
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(videoTitle)
                                .font(.headline)
                                .foregroundColor(.white)
                                .lineLimit(2)
                        }
                        .padding(.top, 23)
                        .padding(.leading, 50)

                        Spacer()

                        HStack(spacing: 10) {
                            CaptionToggleButton(captionsEnabled: $captionsEnabled) { enabled in
                                controller.toggleCaptions(enable: enabled)
                            }
                            .padding()
                            
                            SettingsOptionButton(systemImage: "pip") {
                                controller.startPictureInPicture()
                            }
                            .disabled(!controller.isPipSupported)
                            
                            SettingsOptionButton(systemImage: "video.circle") {
                                withAnimation {
                                    showBitrate = true
                                }
                            }

                            SettingsOptionButton(systemImage: "gear") {
                                withAnimation {
                                    showSettings = true
                                }
                            }
                        }
                        .foregroundColor(.white)
                    }
                    .padding()
                    Spacer()
                }

                // Bottom Controls
                VStack {
                    Spacer()
                    /*
                    HStack {
                        PlaybackControlBarView(
                            currentTime: controller.currentTime,
                            duration: controller.duration,
                            onSeek: { newTime in
                                controller.seek(to: newTime)
                            }
                        )
                        .padding(.bottom, 10)
                        
                        Spacer()
                        
                        SettingsOptionButton(systemImage: "timer") {
                            withAnimation {
                                showSpeedSelector = true
                            }
                        }
                        .padding(.bottom, 20)
                        .padding(.trailing, 15)
                    } */
                }

                if isPlaybackVisible {
                    PlaybackControlsView(
                        isPlaying: $isPlaying,
                        onPlayPause: { isPlaying in
                            isPlaying ? controller.play() : controller.pause()
                        },
                        onSeekForward: {
                            controller.seekForward()
                        },
                        onSeekBackward: {
                            controller.seekBackward()
                        }
                    )
                }
                
            // Settings Bottom Sheet with Fade Background
            if showSettings {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation {
                            showSettings = false
                        }
                    }

                SettingsView(
                    showSettings: $showSettings,
                    captionsEnabled: $captionsEnabled,
                    controller: controller
                )
                .frame(width: 300, height: 250)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(radius: 10)
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
            
            // Settings Bottom Sheet with Fade Background
            if showBitrate {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation {
                            showBitrate = false
                        }
                    }
                
                BitrateSelectionView(controller: controller, showBitrate: $showBitrate)
                .frame(width: 300, height: 320)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(radius: 10)
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
            
            if showSpeedSelector {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation {
                            showSpeedSelector = false
                        }
                    }
                SpeedSelectionView(controller: controller, showSpeedSelector: $showSpeedSelector)
                .frame(width: 300, height: 220)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(radius: 10)
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showSettings)
        .edgesIgnoringSafeArea(.all)
        .background(.black)
        .onTapGesture {
            if showSettings {
                withAnimation {
                    showSettings = false
                }
            } else if !isPlaybackVisible {
                showPlaybackControls()
            }
        }
        .onAppear {
            showPlaybackControls()
            print("Playing video: \(videoURL)")
            /*DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                controller.requestAds()
            }*/
        }
        .onDisappear {
            controller.pause()
        }
    }

    private func showPlaybackControls() {
        isPlaybackVisible = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            isPlaybackVisible = false
        }
    }
}


/*
#Preview {
    VideoPlayerScreen(videoID: ""))
}*/

