//
//  LogixVideoPlayer.swift
//  News18AppleTV
//
//  Created by Mohan R on 30/10/24.
//

import Combine
import SwiftUI
import Kingfisher


// swiftlint:disable type_body_length
struct LogixVideoPlayer: View {
    var category: String
    @State var videoData: VideoData
    @Binding var isPresentingLogixPlayer: Bool
    @Binding var mute: Bool
    @Binding var showAds: Bool
    @FocusState private var focusedSection: TrapFocusSection?
    @EnvironmentObject var sideMenuViewModel: SideMenuViewModel
    @StateObject private var playbackViewModel = PlaybackViewModel()
    @State private var playerController: PlayerContainerViewController?
    @State private var hideTime = 5.0
    @State private var showTrackSelectionView = false // Controls the modal visibility
    var isLiveContent:Bool = false
    @State private var savedSingleOption: String? = "Auto"
    @State private var showControlls:Bool = false
    @State var hidePlayPauseWhenOverLayInHome:Bool = false
    @State private var  hascontentstarted: Bool = true
    @State private var isContentStarted: Bool = true
    @State private var showThumbnail: Bool = true
    @State private var retryCount: Int = 0
    @State private var isHomeLivePlayer: Bool = false
    @State private var isAdPlaying: Bool = false
    
    var onExit: (() -> Void)?
    var videoIsStartPlaying: (() -> Void)?
    var onDismiss: () -> Void
    
    enum FocusSection: Hashable {
        case liveTV
        case playerControls
        case channelList
        case settings
        case otherLiveTvChannels
        case playPause
        case none
    }
    
    // MARK: - Focus Section Enum
    enum TrapFocusSection: Hashable {
        case trapFocused1
        case trapFocused2
        case playPause
    }
    var body: some View {
        ZStack {
            // Make base player view non-focusable when track selection is shown
            videoPlayerView
        }
        .onAppear {
            print("**** loading LogixVideoPlayer")
            playbackViewModel.destroyPlayer()
            initializePlayerIfNeeded()
            DispatchQueue.main.async {
                setupView()
            }
            addObservers()
        }
        .onMoveCommand { direction in
            if showTrackSelectionView {
                // Prevent any focus movement when track selection is shown
                return
            }
            handleMoveCommand(direction)
        }
        .onDisappear {
            cleanup()
        }
        .onPlayPauseCommand(perform: togglePlayback)
        .onExitCommand {
            isPresentingLogixPlayer = false
        }
        .fullScreenCover(isPresented: $showControlls) {
            LivePlayerControlsView(playBackViewModel: playbackViewModel, presentPlayPauseScreen: $showControlls, dismissTheControllers: {
                isPresentingLogixPlayer = false
            }, settingsButtonTapped: {
            })
        }
        .onCompatibleChange(of: playbackViewModel.playerState) { oldValue, newValue in
            if oldValue != newValue {
                handlePlayerState()
            }
        }
        .onCompatibleChange(of: focusedSection) { oldValue, newValue in
            if newValue == .trapFocused2 {
                if !showControlls {
                    showControlls = true
                    focusedSection = .playPause
                }
            }
        }
        .onReceive(playbackViewModel.$progress) { progress in
            let currentDuration = progress?.currentDuration ?? 0
            if currentDuration > 1.0 {
                showThumbnail = false
            }
        }
    }
    private func handleMoveCommand(_ direction: MoveCommandDirection) {
        // Cancel existing timer and reset visibility
        if showControlls == false {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                focusedSection = .playPause
                showControlls = true
            }
            return
        }
    }

    // Example of a focusable player controls view
    private var videoPlayerView: some View {
        ZStack {
            if let playerController {
                PlayerView(playerController: playerController)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    private func initializePlayerIfNeeded() {
        if playerController == nil {
            playerController = PlayerContainerViewController()
        }
    }

    private var heroOverlay: some View {
        ZStack {
            Image("hero_overlay")
            .padding(.top, 120)
            .padding(.leading, 74)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .opacity(showControlls ? 1 : 0)
    }
    
    private func settingsButtonAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showTrackSelectionView.toggle()
        }
    }

    private func setupView() {
        initializePlayer(vid: videoData)
        showControlls = false
    }

    private func togglePlayback() {
        if playbackViewModel.isPlaying() {
            playbackViewModel.pause()
        } else {
            playbackViewModel.play()
        }

    }
    
    private func initializePlayer(vid:VideoData) {
        if let playerController {
            hascontentstarted = true
            isContentStarted = true
            playbackViewModel
                .preparePlayer(
                    with: videoData,
                    playerContainerView: playerController.videoView,
                    showAds: showAds)
        }
    }

    private func cleanup() {
        print("LogixVideoPlayer onDisappear")
        isPresentingLogixPlayer = false
        showControlls = false
        playbackViewModel.destroyPlayer()
        playerController = nil
        removeObservers()
    }
    
    private func handlePlayerState() {
        print(" **** handlePlayerState = ", playbackViewModel.playerState)
        if playbackViewModel.playerState == .endedPlayback {
            cleanup()
        }
        
        if playbackViewModel.playerState ==  .showingAds {
            isAdPlaying = true
            showControlls = !isAdPlaying
        } else  if playbackViewModel.playerState == .hiddenAds {
            // Ad ended
            if isAdPlaying {
                isAdPlaying = false
                showControlls = !isAdPlaying
            }
        }
    }
    
}
// MARK: - App background state
extension LogixVideoPlayer {
    private func addObservers() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            playbackViewModel.pause()
        }
    }
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}
