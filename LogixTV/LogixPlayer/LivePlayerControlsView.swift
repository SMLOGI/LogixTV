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
    @State private var isUserSeeking = false

    // MARK: - Callbacks
    let dismissTheControllers: () -> Void
    let settingsButtonTapped: () -> Void
    
    // MARK: - Focus Enum
    enum FocusSection: Hashable {
        case playPause
        case trap
        //case trap(position: TrapPosition)
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
                // MARK: - Trap Buttons (4 Directions)
               /* ForEach(FocusSection.TrapPosition.allCases, id: \.self) { position in
                    trapButton(for: position)
                }
                */
                shaddowTrappedView
            }
            
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
                                isUserSeeking = false
                            }
                        },
                        focusedSection: $focusedSection,
                        isUserSeeking: $isUserSeeking
                    )
            }
            .padding(.bottom, 40)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: handleAppear)
        .onDisappear(perform: resetHideTimer)
        .onCompatibleChange(of: presentPlayPauseScreen) { _, newValue in
            if !newValue { dismissTheControllers() }
        }
        .onCompatibleChange(of: focusedSection, perform: { oldValue , newValue in
            if !isShowPlayPauseButton {
                if oldValue == .progressBar && newValue == .trap {
                    handleAppear()
                }
            }
        })
        .onExitCommand(perform: handleExitCommand)
        .ignoresSafeArea()
    }
    
    private var shaddowTrappedView: some View {
        Color.clear
            .frame(width: 50, height: 50)
            .focusable(true)
            .focused($focusedSection, equals: .trap)
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
        let task = DispatchWorkItem { isShowPlayPauseButton = false }
        hideWorkItem = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: task)
    }
    
    func handleExitCommand() {
        dismissTheControllers()
        presentPlayPauseScreen = false
        globalNavState.activeScreen = nil
    }
}

// MARK: - UI Builders
/*
private extension LivePlayerControlsView {
    
    func trapButton(for position: FocusSection.TrapPosition) -> some View {
        let offset: CGFloat = 120 // Distance from center
        
        return Circle()
            .fill(Color.red.opacity(0.9))
            .frame(width: size(for: position), height: size(for: position))
            .focusable(true)
            .focused($focusedSection, equals: .trap(position: position))
            .offset(offsetFor(position))
            .animation(.easeInOut(duration: 0.2), value: focusedSection)
    }
    
    func size(for position: FocusSection.TrapPosition) -> CGFloat {
        if case .trap(let focusedPos)? = focusedSection {
            return focusedPos == position ? 90 : 70
        }
        return 70
    }
    
    func offsetFor(_ position: FocusSection.TrapPosition) -> CGSize {
        switch position {
        case .top: return CGSize(width: 0, height: -120)
        case .bottom: return CGSize(width: 0, height: 120)
        case .left: return CGSize(width: -120, height: 0)
        case .right: return CGSize(width: 120, height: 0)
        }
    }
}
*/
