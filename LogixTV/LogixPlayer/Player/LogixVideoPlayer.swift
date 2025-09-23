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
    @Binding var showControls: Bool
    @Binding var mute: Bool
    @Binding var showAds: Bool
    @FocusState private var focusedSection: FocusSection?
    @EnvironmentObject var sideMenuViewModel: SideMenuViewModel
    @StateObject private var playbackViewModel = PlaybackViewModel()
    @State private var playerController: PlayerContainerViewController?
    @State private var hideTime = 5.0
    @State private var showTrackSelectionView = false // Controls the modal visibility
    var isLiveContent:Bool = false
    @State private var savedSingleOption: String? = "Auto"
    @State private var showLiveControlls:Bool = false
    @State var hidePlayPauseWhenOverLayInHome:Bool = false
    @State private var showChannelList: Bool = false
    @State private var  hascontentstarted: Bool = true
    @State private var isContentStarted: Bool = true
    @State private var showThumbnail: Bool = true
    @State private var retryCount: Int = 0
    @State private var isHomeLivePlayer: Bool = false

    var onExit: (() -> Void)?
    var videoIsStartPlaying: (() -> Void)?
    @Binding var isPresentingTheScreen: Bool
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
    

    var body: some View {
        ZStack {
            // Make base player view non-focusable when track selection is shown
            videoPlayerView
        
        }
        .onAppear {
            playbackViewModel.destroyPlayer()
            initializePlayerIfNeeded()
            DispatchQueue.main.async {
                setupView()
            }
            addObservers()
        }
        .onDisappear {removeObservers()}
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
            isPresentingTheScreen = false
        }
        .fullScreenCover(isPresented: $showControls) {
            LivePlayerControlsView(playBackViewModel: playbackViewModel, dismissTheControllers: {
                showControls = false
                isPresentingTheScreen = false
            }, settingsButtonTapped: {
                showControls = false
                settingsButtonAction()
            })
        }
        //.onChange(of: playbackViewModel.playerState, perform: handlePlayerState)
       // .onChange(of: playbackViewModel.isPlaying(), perform: checkVideoIsStartPlaying)
        .onReceive(playbackViewModel.$progress) { progress in
            let currentDuration = progress?.currentDuration ?? 0
            if currentDuration > 1.0 {
                showThumbnail = false
            }
        }
    }
    private func handleMoveCommand(_ direction: MoveCommandDirection) {
        // Cancel existing timer and reset visibility
        if showControls == false && !showChannelList{

            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                focusedSection = .playPause
                showControls = true
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
        .opacity(showLiveControlls ? 1 : 0)
    }
    
    private func settingsButtonAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showTrackSelectionView.toggle()
        }
    }

    private func setupView() {
        showChannelList = false
        initializePlayer(vid: videoData)
        showControls = false
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
            playbackViewModel.destroyPlayer()
            playerController = nil
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
