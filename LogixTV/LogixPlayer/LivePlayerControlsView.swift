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
    
    // MARK: - States
    @FocusState private var focusedSection: FocusSection?
    @State private var hideWorkItem: DispatchWorkItem?
    @State private var isShowPlayPauseButton = false
    @State private var isLoading = false
    @EnvironmentObject var globalNavState: GlobalNavigationState
    
    // MARK: - Callbacks
    let dismissTheControllers: () -> Void
    let settingsButtonTapped: () -> Void
    
    // MARK: - Focus Enum
    enum FocusSection: Hashable {
        case playPause
        case trap
        case trapLeft
        case trapRight
        case trapTop
        case trapBottom
        case progressBar
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
                shaddowTrappedView
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
