//
//  LivePlayerControlsView.swift
//  News18AppleTV
//
//  Created by Joshua Sebastin on 14/04/25.
//

import SwiftUI

// MARK: - Main View
struct LivePlayerControlsView: View {
    
    // MARK: - ViewModel Observers
    @ObservedObject var playBackViewModel: PlaybackViewModel
    
    // MARK: - Focus States
    @FocusState private var focusedSection: FocusSection?
    
    // MARK: - States
    @State private var showControls: Bool = true
    @State private var hideWorkItem: DispatchWorkItem?
    @State private var blinkingOpacity: Double = 1.0
    @State private var showChannelList: Bool = false
    
    // MARK: - Callbacks
    let dismissTheControllers: () -> Void
    let settingsButtonTapped: () -> Void
    @State private var isLoading = false
    // MARK: - Focus Section Enum
    enum FocusSection: Hashable {
        case trapFocused1
        case trapFocused2
        case playPause
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {

           // if (playBackViewModel.isShowingAd == false) {
                if showControls {
                    PlayerControlButton(
                        imageName: playBackViewModel.isPlaying() ? "PlayButtonUnfocused" : "PauseButtonUnfocused",
                        focusedImageName: playBackViewModel.isPlaying() ? "pause" : "play",
                        action: togglePlayPause
                    )
                    .focused($focusedSection, equals: .playPause)
                    .onAppear {
                        print("****** PlayerControlButton onAppear called")
                        resetHideTimer()
                    }
  
                }
                
                bottomTrailingView
                    .padding(.bottom, 400)

           // }

            /*
            if isLoading {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                PulsingDots()
            }
            */
        }
        .onAppear {
            print("****** LivePlayerControlsView onAppear called")
            focusedSection = .playPause
        }
        .onDisappear {
            resetTime()
        }
        .onCompatibleChange(of: showControls) { _, newValue in
            if !newValue {
               // dismissTheControllers()
            }
        }
        .onCompatibleChange(of: focusedSection) { oldValue, newValue in
            if newValue == .trapFocused2 {
                if !showControls {
                    showControls = true
                    focusedSection = .playPause
                }
            }
        }
        // MARK: - Moved logic to a separate method
        // MARK: - Moved logic to a separate method
        .onExitCommand(perform: handleExitCommand)
        .ignoresSafeArea()
    }
}

// MARK: - Private Methods
extension LivePlayerControlsView {
    
    private func togglePlayPause() {
        if playBackViewModel.isPlaying() {
            playBackViewModel.pause()
        } else {
            playBackViewModel.play()
        }
    }
    
    private func resetHideTimer() {
        hideWorkItem?.cancel()
        let task = DispatchWorkItem {
            if hideWorkItem != nil {
                showControls = false
            }
        }
        hideWorkItem = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: task)
    }
    
    private func resetTime() {
        hideWorkItem = nil
    }
    
    // MARK: - Separate Logic
    
    private func handleExitCommand() {
            dismissTheControllers()
    }
}

// MARK: - Live Blinker and Settings
extension LivePlayerControlsView {
    
    private var isTrapOneFocused: Bool {
        focusedSection == .trapFocused1
    }
    
    private var sizeForFocused: CGFloat {
        isTrapOneFocused ? 100 : 90
    }
    
    private var isTrapTwoFocused: Bool {
        focusedSection == .trapFocused2
    }
    
    private var size2ForFocused: CGFloat {
        isTrapTwoFocused ? 100 : 90
    }
    
    
    private var bottomTrailingView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Color.clear
                .frame(width: sizeForFocused, height: sizeForFocused)
                .focusable(true)
                .focused($focusedSection, equals: .trapFocused1)
            
            Color.clear
                .frame(width: size2ForFocused, height: sizeForFocused)
                .focusable(true)
                .focused($focusedSection, equals: .trapFocused2)
        }
    }
    
    private var liveNowBlinkingView: some View {
        HStack(spacing: 10) {
            LiveBlinker()
            Text("LIVE")
                .font(.robotoBold(size: 24))
                .foregroundColor(Color.white)
                .opacity(blinkingOpacity)
        }
    }
    
    private func settingsButtonAction() {
        settingsButtonTapped()
    }
}
