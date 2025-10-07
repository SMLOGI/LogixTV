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
    @State        private var emptyViewShouldInFocus = true
    @FocusState private var trapFocused:  Bool
    @State private var isLoading = false
    // MARK: - Focus Section Enum
    enum FocusSection: Hashable {
        case channelList
        case settings
        case otherLiveTvChannels
        case playPause
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {

            if (playBackViewModel.isShowingAd == false) {
                PlayerControlButton(
                    imageName: playBackViewModel.isPlaying() ? "PlayButtonUnfocused" : "PauseButtonUnfocused",
                    focusedImageName: playBackViewModel.isPlaying() ? "pause" : "play",
                    action: togglePlayPause
                )
                .focused($focusedSection, equals: .playPause)
            }
            if isLoading {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                PulsingDots()
            }
        }
        .onChange(of: trapFocused) { newIdx in
            focusedSection = .playPause
        }
        .onAppear {
            focusedSection = .playPause
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isLoading = false
            }
            resetHideTimer()
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
            if newValue != nil && oldValue != newValue {
                resetHideTimer()
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
            if hideWorkItem != nil && !showChannelList {
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
    
    private var bottomTrailingView: some View {
        VStack {
            VStack {
                Color.clear
                    .frame(width: 100, height: 100)
                    .focusable(emptyViewShouldInFocus)
                    .focused($trapFocused)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 100)
            HStack(spacing: 20) {
                liveNowBlinkingView
                PlayerControlButton(
                    imageName: "settings",
                    focusedImageName: "settings",
                    buttonSize: 60,
                    action: settingsButtonAction
                )
                .focused($focusedSection, equals: .settings)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 40)
        }
        .focusSection()
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

// MARK: - Other Live TV Channels
extension LivePlayerControlsView {
        
    private var bottomHeaderTextView: some View {
        VStack {
            HStack(alignment: .center, spacing: 8) {
                Text("OTHER LIVE TV CHANNELS")
                    .foregroundColor(.white)
                    .font(.robotoBold(size: 24))
                
                Image(!showChannelList ? "Down Arrow" : "upload")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                focusedSection == .otherLiveTvChannels
                ? Color.gray.opacity(1)
                : Color.clear
            )
            .cornerRadius(8)
            .animation(.easeInOut, value: focusedSection)
            .focusable(!showChannelList)
            .focused($focusedSection, equals: .otherLiveTvChannels)
            .onTapGesture {
                withAnimation {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        focusedSection = .channelList
                        showChannelList.toggle()
                        resetTime()
                    }
                }
            }
        }
        .padding(.bottom, 35)
    }
}
