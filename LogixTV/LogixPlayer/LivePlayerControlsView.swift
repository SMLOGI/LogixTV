//
//  LivePlayerControlsView.swift
//  News18AppleTV
//
//  Created by Joshua Sebastin on 14/04/25.
//

import SwiftUI

// MARK: - Focus Enum


struct LivePlayerControlsView: View {
    
    enum ControlFocus: Hashable {
        case playPause
        case trap
        case trapLeft
        case trapRight
        case trapTop
        case trapBottom
        case progressBar
        case goLiveButton
        case  subtitles
        case settings
        case  episodes
        case next
    }
    
    // MARK: - ViewModel
    @ObservedObject var playBackViewModel: PlaybackViewModel
    
    // MARK: - Bindings
    @Binding var presentPlayPauseScreen: Bool

    // MARK: - States
    @FocusState private var focusedControl: ControlFocus?
    @State private var hideWorkItem: DispatchWorkItem?
    @State private var isShowPlayPauseButton = false
    @State private var isLoading = false
    @EnvironmentObject var globalNavState: GlobalNavigationState
    
    // MARK: - Callbacks
    let dismissTheControllers: () -> Void
    let settingsButtonTapped: () -> Void
    
    // MARK: - Body
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {

                if isShowPlayPauseButton {
                    VStack() {
                        Spacer()
                        
                        VStack(spacing: 20.0) {
                            HStack(spacing: 40.0) {
                                TVPlayPauseIcon(
                                    icon: playBackViewModel.isPlaying() ? "pause.fill" : "play.fill",
                                    size: 38,
                                    cornerRadius: 2
                                ) {
                                    togglePlayPause()
                                }
                                .focused($focusedControl, equals: .playPause)
                                //.onAppear(perform: resetHideTimer)
                                
                                
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
                                    focusedSection: $focusedControl,
                                    isUserSeeking: $playBackViewModel.isUserSeeking,
                                    barWidth: proxy.size.width * (globalNavState.isShowMutiplayerView ? 0.60 : 0.85)
                                )
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity)
                            
                            HStack {
                                controlButton(title: "Subtitle & Audio", icon: "captions.bubble.fill")
                                    .focused($focusedControl, equals: .subtitles)
                                
                                controlButton(title: "Settings", icon: "gearshape.fill")
                                    .focused($focusedControl, equals: .settings)
                                
                                controlButton(title: "Episodes", icon: "list.bullet.rectangle")
                                    .focused($focusedControl, equals: .episodes)
                                
                                controlButton(title: "Next Episode", icon: "forward.end.fill")
                                    .focused($focusedControl, equals: .next)
                                
                            }
                            .padding(.bottom, 50)
                            /*
                            TVCardButton(title: "Keynote ON", selectedtitle: "Keynote OFF",  focusedSection: $focusedSection) {
                                globalNavState.isShowMutiplayerView = !globalNavState.isShowMutiplayerView
                            } */
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: handleAppear)
        //.onDisappear(perform: resetHideTimer)
        .onCompatibleChange(of: presentPlayPauseScreen) { _, newValue in
            if !newValue { dismissTheControllers() }
        }
        /*
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
         */
        .onExitCommand(perform: handleExitCommand)
        .ignoresSafeArea()
    }
    
    // MARK: - CONTROL-BUTTON UI
    @ViewBuilder
    private func controlButton(title: String, icon: String) -> some View {
        ZStack {
            Button(action: {}) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 25, weight: .regular))
                    Text(title)
                        .font(.system(size: 25, weight: .regular))
                }
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
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
    func focusBox(for section: ControlFocus) -> some View {
        Color.clear
            .frame(width: 150, height: 150)
            .focusable(true)
            .focused($focusedControl, equals: section)
    }
    func makeVideoData(from item: CarouselContent) -> VideoData? {
        guard let urlString = item.video?.first?.contentUrl,
              let _ = URL(string: urlString) else {
            return nil
        }

        return VideoData(
            type: "vod",
            profile: "pradip",
            drmEnabled: false,
            licenceUrl: "",
            contentUrl: urlString,
            protocol: "",
            encryptionType: "hls",
            adInfo: nil,
            qualityGroup: .none
        )
    }
    
}

// MARK: - Private Methods
private extension LivePlayerControlsView {
    
    func handleAppear() {
        isShowPlayPauseButton = true
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            focusedControl = .playPause
//        }
    }
    
    func togglePlayPause() {
        playBackViewModel.isPlaying() ? playBackViewModel.pause() : playBackViewModel.play()
    }
    
    func resetHideTimer() {
        hideWorkItem?.cancel()
        let task = DispatchWorkItem {
            isShowPlayPauseButton = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focusedControl = .goLiveButton

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
