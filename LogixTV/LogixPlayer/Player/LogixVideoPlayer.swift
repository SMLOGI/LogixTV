//
//  LogixVideoPlayer.swift
//  News18AppleTV
//
//  Created by Mohan R on 30/10/24.
//

import Combine
import SwiftUI
import Kingfisher

// MARK: - Focus Section Enum
enum TrapFocusSection: Hashable {
    case trapFocused1
    case trapFocused2
    case playPause
}

// swiftlint:disable type_body_length
struct LogixVideoPlayer: View {
    var category: String
    @State var videoData: VideoData
    @Binding var isPresentingLogixPlayer: Bool
    @Binding var mute: Bool
    @Binding var showAds: Bool
    @FocusState private var focusedSection: TrapFocusSection?
    @EnvironmentObject var sideMenuViewModel: SideMenuViewModel
    @ObservedObject var playbackViewModel: PlaybackViewModel
    @State private var playerController: PlayerContainerViewController?
    @State private var hideTime = 5.0
    @State private var showTrackSelectionView = false // Controls the modal visibility
    var isLiveContent:Bool = false
    @State private var savedSingleOption: String? = "Auto"
    @State private var showControlls:Bool = false
    @State var hidePlayPauseWhenOverLayInHome:Bool = false
    @State private var  hascontentstarted: Bool = true
    @State private var isContentStarted: Bool = true
    @State private var retryCount: Int = 0
    @Binding var isMainLivePlayer: Bool
    @State private var isAdPlaying: Bool = false
    
    @State private var showPlayer = false
    @EnvironmentObject var globalNavState: GlobalNavigationState

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
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if isLiveContent {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
            
            videoPlayerView

            // Make base player view non-focusable when track selection is shown
            if !showPlayer {
                if let url = URL(string: videoData.licenceUrl) {
                    CachedAsyncImage(url: url)
                        .scaledToFill()
                        .clipped()
                        .ignoresSafeArea()
                } else {
                    //Color.gray
                }
                
                LoadingView()
            } else {
                if !globalNavState.isPiPMutiplayerView || !isMainLivePlayer {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            if showControlls {
                                Text(videoData.title)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 2)
                                    .font(.system(size: 35, weight: .regular))
                                    .foregroundColor(.white)
                                    .background(
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(Color.black.opacity(0.25))
                                    )
                                    .padding(.top, 40) // distance from bottom
                                    .padding(.leading, 20)
                                
                                Spacer()
                            }
                            Spacer()
                        }
                        .ignoresSafeArea()
                        Spacer()
                        
                    }
                    .ignoresSafeArea()
                }
            }
        }
        .onAppear {
            print("**** loading LogixVideoPlayer = \(videoData.contentUrl)")
            playbackViewModel.destroyPlayer()
            playerController = nil
            removeObservers()
            initializePlayerIfNeeded()
            DispatchQueue.main.async {
                setupView()
            }
            showPlayer = false
            isAdPlaying = showAds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeIn(duration: 0.2)) {
                    showPlayer = true
                }
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
        .onPlayPauseCommand(perform: togglePlayback)
        .onExitCommand {
            //cleanup()
            print("**** onExitCommand LogixVideoPlayer")
            isPresentingLogixPlayer = false
        }
        .fullScreenCover(isPresented: $showControlls) {
            LivePlayerControlsView(playBackViewModel: playbackViewModel, presentPlayPauseScreen: $showControlls, isLiveContent: videoData.isLiveContent,  isMainLivePlayer: $isMainLivePlayer, dismissTheControllers: {
                //isPresentingLogixPlayer = false
                // globalNavState.activeScreen = nil
                print("**** fullScreenCover LivePlayerControlsView  dismissTheControllers = \(videoData.contentUrl)")
                // cleanup()
            }, destroyTapped: {
                cleanup()
            }, refreshTapped: {
               // refresh()
            }
            )
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
                    .onCompatibleChange(of: globalNavState.isPiPMutiplayerView) { oldVlaue, newValue in
                        // *** IMP
                        print("*** Transition of pip player to live again newValue =\(newValue) && isMainLivePlayer = \(isMainLivePlayer) ***")
                        if isMainLivePlayer {
                            if newValue {
                                playbackViewModel.mute()
                                print("*** Transition of main player to pip player and playing side video")
                            } else {
                                // cleanup()
                                print("*** Transition of pip player to live again")
                                playbackViewModel.unMute()
                            }
                        } else {
                            if newValue == false {
                                playbackViewModel.destroyPlayer()
                                removeObservers()
                            }
                        }
                    }
            }
        }
    }
    
    private func initializePlayerIfNeeded() {
        if playerController == nil {
            playerController = PlayerContainerViewController()
            print("*** PlayerContainerViewController()")
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
        print("*** LogixVideoPlayer initializePlayer")

        if let playerController {
            print("*** playerController.videoView \(playerController.videoView)")

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
        globalNavState.activeScreen = nil
        removeObservers()
    }
    
    private func refresh() {
        print(" **** LogixVideoPlayer refresh=", videoData.contentUrl)
        if videoData.isLiveContent && !isMainLivePlayer{
            playbackViewModel.destroyPlayer()
            removeObservers()
            playerController = nil
            initializePlayerIfNeeded()
            DispatchQueue.main.async {
                initializePlayer(vid: videoData)
            }
            addObservers()
        }
    }
    
    private func handlePlayerState() {
        print(" **** handlePlayerState = ", playbackViewModel.playerState)
        if playbackViewModel.playerState == .endedPlayback {
            
            if videoData.isLiveContent  && !isMainLivePlayer{
                let list = globalNavState.dummyMiniPlayerContents
                let index = globalNavState.miniPlayerItemIndex
                let newIndex = (index + 1) % list.count
                globalNavState.miniPlayerItem = nil
                globalNavState.isPiPMutiplayerView = true
                globalNavState.isShowMutiplayerView = false
                globalNavState.miniPlayerItemIndex = newIndex   // ✅ index
                globalNavState.miniPlayerItem = globalNavState.dummyMiniPlayerContents[newIndex]
                // ✅ item
            } else {
                cleanup()
            }
        }
        
        if isAdPlaying {
            if playbackViewModel.playerState ==  .showingAds {
                showControlls = false
            } else  if playbackViewModel.playerState == .hiddenAds {
                // Ad ended
                    showControlls = true
            }
        } else {
            if playbackViewModel.playerState == .readyPlayback || playbackViewModel.playerState ==  .resumedPlayback {
                showControlls = true
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
