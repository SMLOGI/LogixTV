//
//  LivePlayerControlsView.swift
//  News18AppleTV
//
//  Created by Joshua Sebastin on 14/04/25.
//

import SwiftUI

struct LivePlayerControlsView: View {
    
    // MARK: - ViewModel
    @ObservedObject var playBackViewModel: PlaybackViewModel
    
    // MARK: - Bindings
    @Binding var presentPlayPauseScreen: Bool
    var category: String
    
    // MARK: - States
    @FocusState private var focusedSection: FocusSection?
    @State private var hideWorkItem: DispatchWorkItem?
    @State private var isShowPlayPauseButton = false
    @State private var isLoading = false
    @State var videoData: VideoData                // Full-screen video
    @State var videoDataList: [VideoData]          // Mini players on the right
    @EnvironmentObject var globalNavState: GlobalNavigationState
    
    // MARK: - Callbacks
    let dismissTheControllers: () -> Void
    
    // MARK: - Focus Enum
    enum FocusSection: Hashable {
        case playPause
        case trap
        case trapLeft
        case trapRight
        case trapTop
        case trapBottom
        case progressBar
        case miniplayer(Int)
        /*
         enum TrapPosition: CaseIterable {
         case top, bottom, left, right
         }*/
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            if isShowPlayPauseButton {
                // MARK: - Play / Pause Button (Center)
                PlayerControlButton(
                    imageName: playBackViewModel.isPlaying() ? "PlayButtonUnfocused" : "PauseButtonUnfocused",
                    focusedImageName: playBackViewModel.isPlaying() ? "pause" : "play",
                    action: togglePlayPause
                )
                .focused($focusedSection, equals: .playPause)
                .onAppear(perform: resetHideTimer)
            } else  {
                //shaddowTrappedView
            }
            if isShowPlayPauseButton {
                VStack() {
                    Spacer()
                    ProgressSliderView(
                        currentTime: Binding(
                            get: { playBackViewModel.progress?.currentDuration ?? 0 },
                            set: { playBackViewModel.progress?.currentDuration = $0 }
                        ),
                        totalTime:  playBackViewModel.progress?.totalDuration ?? 0.0,
                        onSeek: { newTime in
                            playBackViewModel.seekToPosition(value: Float(newTime)) {
                                playBackViewModel.isUserSeeking = false
                            }
                        },
                        focusedSection: $focusedSection,
                        isUserSeeking: $playBackViewModel.isUserSeeking,
                        barWidth: UIScreen.main.bounds.width - 160
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 40)
            }
            
            HStack {
                
                Spacer()
                
                VStack(spacing: 30) {
                    ForEach(videoDataList.indices, id: \.self) { index in
                        miniPlayer(for: index)
                    }
                }
                .padding()
                .background(
                    Color.black.opacity(0.4)
                )
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: handleAppear)
        .onDisappear(perform: resetHideTimer)
        .onCompatibleChange(of: presentPlayPauseScreen) { _, newValue in
            if !newValue { dismissTheControllers() }
        }
        .onCompatibleChange(of: focusedSection, perform: { oldValue , newValue in
            if !isShowPlayPauseButton {
                if oldValue == .trap {
                    if newValue == .trapTop || newValue == .trapBottom || newValue == .trapLeft || newValue == .trapRight {
                        handleAppear()
                    }
                }
            }
            playBackViewModel.isUserSeeking = false
        })
        .onExitCommand(perform: handleExitCommand)
        .ignoresSafeArea()
    }
    
    
    // --------------------------------------------------
    // MARK: MINI PLAYER VIEW
    // --------------------------------------------------
    @ViewBuilder
    private func miniPlayer(for index: Int) -> some View {
        let smallWidth: CGFloat = 400
        let smallHeight: CGFloat = 250
        //if case focusedSection = .miniPlayer(for: index)
        let isFocused = .miniplayer(index) == focusedSection
        LogixVideoPlayer(
            category: category, isMiniPlayer: true,
            videoData: videoDataList[index],
            isPresentingLogixPlayer: .constant(true),
            mute: .constant(true),
            showAds: .constant(false),
            onDismiss: { }
        )
        .frame(width: smallWidth, height: smallHeight)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        
        // White border when focused
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? Color.white : Color.clear, lineWidth: 6)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        )
        
        .focusable(true)
        .focused($focusedSection, equals: .miniplayer(index))
        .onTapGesture {
            swapToFullScreen(index)
        }
    }
    
    
    // --------------------------------------------------
    // MARK: SWAP MAIN ↔ MINI PLAYER
    // --------------------------------------------------
    private func swapToFullScreen(_ index: Int) {
        withAnimation(.easeInOut(duration: 0.35)) {
            
            let tapped = videoDataList[index]
            videoDataList[index] = videoData
            videoData = tapped
            
            // Keep focus on the same mini player index after swap
            focusedSection = .miniplayer(index)
        }
    }
    private var shaddowTrappedView: some View {
        VStack(spacing: 20) {
            focusBox(for: .trapTop)
            HStack(spacing: 20) {
                // Left
                focusBox(for: .trapLeft)
                // Center
                focusBox(for: .trap)
                // Right
                focusBox(for: .trapRight)
            }
            // Bottom item
            focusBox(for: .trapBottom)
        }
    }
    
    // Reusable item box
    @ViewBuilder
    func focusBox(for section: FocusSection) -> some View {
        Color.clear
            .frame(width: 150, height: 150)
            .focusable(true)
            .focused($focusedSection, equals: section)
    }
}

// MARK: - Private Methods
private extension LivePlayerControlsView {
    
    func handleAppear() {
        isShowPlayPauseButton = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            focusedSection = .playPause
        }
    }
    
    func togglePlayPause() {
        playBackViewModel.isPlaying() ? playBackViewModel.pause() : playBackViewModel.play()
    }
    
    func resetHideTimer() {
        hideWorkItem?.cancel()
        let task = DispatchWorkItem {
            isShowPlayPauseButton = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focusedSection = .trap

            }
        }
        hideWorkItem = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: task)
    }
    
    func handleExitCommand() {
        dismissTheControllers()
        presentPlayPauseScreen = false
        globalNavState.activeScreen = nil
    }
}
