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
        //case goLiveButton
        case  subtitles
        case settings
        case episodes
        case next
        case miniPlayer(Int)
        case goLive
        case Close
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
    var isLiveContent = false
    @Binding var isMainLivePlayer: Bool
    // MARK: - Callbacks
    let dismissTheControllers: () -> Void
    let destroyTapped: () -> Void
    let refreshTapped: () -> Void
    
    let dummyMiniPlayerContents: [MiniPlayerContent] = [
        MiniPlayerContent(
            id: 1,
            contentUrl: "https://logix-cms-content.s3.ap-south-1.amazonaws.com/content/transcoded/f7338b9d8ef7f45e09e350ebhls/f7338b9d8ef7f45e09e3.m3u8",
            title: "Video 1",
            imageUrl: "https://logix-cms-content.s3.ap-south-1.amazonaws.com/content/actual/OG46p5YXZd/image/63e4a9452fb121ddcc0f.jpg",
            description: nil,
            duration: 10
        ),
        MiniPlayerContent(
            id: 2,
            contentUrl: "https://logix-cms-content.s3.ap-south-1.amazonaws.com/content/transcoded/d29b5a4f23d3950a482c9942hls/d29b5a4f23d3950a482c.m3u8",
            title: "Video 2",
            imageUrl: "https://logix-cms-content.s3.ap-south-1.amazonaws.com/content/actual/zOFl4OAAfE/image/7b4ab07864c341145c06.jpg",
            description: nil,
            duration: 20
        ),
        MiniPlayerContent(
            id: 3,
            contentUrl: "https://logix-cms-content.s3.ap-south-1.amazonaws.com/content/transcoded/700014a448283ef854f9968dhls/700014a448283ef854f9.m3u8",
            title: "Video 3",
            imageUrl: "https://logix-cms-content.s3.ap-south-1.amazonaws.com/content/actual/6fuHEXFIK7/image/4aced505662191ef0a69.jpg",
            description: nil,
            duration: 30
        ),
        MiniPlayerContent(
            id: 4,
            contentUrl: "https://logix-cms-content.s3.ap-south-1.amazonaws.com/content/transcoded/374d9ebaf2582919daf9353ehls/374d9ebaf2582919daf9.m3u8",
            title: "Video 4",
            imageUrl: "https://logix-cms-content.s3.ap-south-1.amazonaws.com/content/actual/ojM19JAoRS/image/7ae5b58d947ec9f003bc.jpg",
            description: nil,
            duration: 40
        ),
        MiniPlayerContent(
            id: 5,
            contentUrl: "https://logix-cms-content.s3.ap-south-1.amazonaws.com/content/transcoded/11571f6a6f8ac08363912223hls/11571f6a6f8ac0836391.m3u8",
            title: "Video 5",
            imageUrl: "https://logix-cms-content.s3.ap-south-1.amazonaws.com/content/actual/4EtxSY8vR6/image/56087addee29137531ba.jpg",
            description: nil,
            duration: 50
        )
    ]

    /*
    let dummyMiniPlayerContents: [MiniPlayerContent] = [
        MiniPlayerContent(
            id: 1,
            contentUrl: "https://logix-cms-content.s3.ap-south-1.amazonaws.com/content/transcoded/6d9a24901765e1d0abd6b38ehls/6d9a24901765e1d0abd6.m3u8",
            title: "Adventure Story",
            imageUrl: "https://logix-cms-content.s3.ap-south-1.amazonaws.com/content/actual/cwjN0C42Z3/images/1.jpg",
            description: "A fun and exciting mini adventure.",
            duration: 120
        ),
        MiniPlayerContent(
            id: 2,
            contentUrl: "https://logix-cms-content.s3.ap-south-1.amazonaws.com/content/transcoded/a758ef717ea30794c0c47eeahls/a758ef717ea30794c0c4.m3u8",
            title: "Learning Time",
            imageUrl: "https://logix-cms-content.s3.ap-south-1.amazonaws.com/content/actual/1wkJWVGNfj/images/2.jpg",
            description: "An engaging educational clip for kids.",
            duration: 150
        ),
        MiniPlayerContent(
            id: 3,
            contentUrl: "https://logix-cms-content.s3.ap-south-1.amazonaws.com/content/transcoded/133e62288e629f54990f76d6hls/133e62288e629f54990f.m3u8",
            title: "Fun With Friends",
            imageUrl: "https://logix-cms-content.s3.ap-south-1.amazonaws.com/content/actual/7ZFxIl7h81/images/3.jpg",
            description: "A joyful moment full of fun and laughter.",
            duration: 180
        )
    ]
     */
    
    // MARK: - Body
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {

                if isShowPlayPauseButton {
                    VStack() {
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 0.0) {
                            HStack(alignment: .bottom, spacing: 40.0) {
                                TVPlayPauseIcon(
                                    icon: playBackViewModel.isPlaying() ? "pause.fill" : "play.fill",
                                    size: 38,
                                    cornerRadius: 2
                                ) {
                                    togglePlayPause()
                                }
                                .focused($focusedControl, equals: .playPause)
                                //.onAppear(perform: resetHideTimer)
                                .onMoveCommand(perform: movePlayPause)
                                
                                if !isMainLivePlayer || !isLiveContent {
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
                                        isUserSeeking: $playBackViewModel.isUserSeeking
                                    )
                                    
                                    if globalNavState.isShowMutiplayerView {
                                        VStack {
                                            Rectangle()
                                                .frame(width: 356, height: 80)
                                                .background(Color.black)
                                        }
                                    }
                                } else {
                                    Spacer()
                                     //   .frame(width:  globalNavState.isShowMutiplayerView ? 380 : 10)
                                }
                            }
                            .padding(.horizontal, 20)
                           // .padding(.bottom, globalNavState.isShowMutiplayerView ? 60 : 10)
                            .padding(.bottom, !isLiveContent ? 40: -10)
                            .frame(maxWidth: .infinity)
                            
                            if isLiveContent {
                               // if !globalNavState.isShowMutiplayerView {
                                showBottomTabButtons
                              //  }
                            }
                        }
                    }
                    
                    if globalNavState.isShowMutiplayerView {
                        HStack(alignment: .top) {
                            Spacer()
                            ScrollView {
                                VStack(alignment: .leading) {
                                    Spacer()
                                        .frame(height: 100)
                                    ForEach(dummyMiniPlayerContents.indices, id: \.self) { index in
                                        let item = dummyMiniPlayerContents[index]
                                        
                                        MiniPlayerCardButtonView(
                                            item: item,
                                            focusedControl: $focusedControl
                                        ) {
                                            // ignore same item click twice
                                            guard globalNavState.miniPlayerItemIndex != index else { return }
                                            globalNavState.miniPlayerItem = nil
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                globalNavState.isPiPMutiplayerView = true
                                                globalNavState.isShowMutiplayerView = false
                                            }
                                            globalNavState.miniPlayerItemIndex = index   // ✅ index
                                            globalNavState.miniPlayerItem = item         // ✅ item
                                            print("*** MiniPlayerCardButtonView clicked for index = \(index) and item =\(item.contentUrl)")
                                            refreshTapped()
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                focusedControl = .goLive
                                            }
                                        }
                                    }
                                    Spacer()
                                        .frame(height: 100)
                                }
                                .frame(width: 426)
                            }
                            .frame(width: 426)
                            .padding(.leading, 0)
                            .background(Color.black)
                            .onMoveCommand(perform: moveNext)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if let itemId = dummyMiniPlayerContents.first?.id {
                                    focusedControl = .miniPlayer(itemId)
                                }
                            }
                        }
                    }
                }

                if isLiveContent  {
                    HStack(alignment: .top) {
                        Spacer()
                        VStack(alignment: .leading) {
                            Spacer()
                            LiveNowButton(size: (isMainLivePlayer ? .regular :  .small)) {
                                globalNavState.isPiPMutiplayerView = false
                                globalNavState.miniPlayerItem = nil
                                globalNavState.miniPlayerItemIndex = -1
                                focusedControl = .goLive
                            }
                            .padding(.bottom, isMainLivePlayer ? 80 : 130)
                            .padding(.trailing, isMainLivePlayer ? 50 : 110)
                            .focused($focusedControl, equals: .goLive)
                            .onMoveCommand(perform: moveLivePlayer)
                            //.focusable(!isMainLivePlayer)
                        }
                    }
                    .padding(.trailing, globalNavState.isShowMutiplayerView ? 380 : 0)

                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: handleAppear)
        //.onDisappear(perform: resetHideTimer)
        .onCompatibleChange(of: presentPlayPauseScreen) { _, newValue in
            print("*** onCompatibleChange presentPlayPauseScreen newValu=\(newValue)")
            if !newValue {
                dismissTheControllers()
            }
        }
        
        .onCompatibleChange(of: focusedControl, perform: { oldValue , newValue in
            /*if !isShowPlayPauseButton {
                if oldValue == .trap {
                    if newValue == .trapTop || newValue == .trapBottom || newValue == .trapLeft || newValue == .trapRight {
                        handleAppear()
                    }
                }
            }
            playBackViewModel.isUserSeeking = false
             */
            globalNavState.isGoLiveFocused = newValue == .goLive
            if oldValue == .progressBar {
                if newValue == .subtitles || newValue == .settings || newValue == .episodes || newValue == .next {
                    focusedControl = .subtitles
                }
            }
            /*
            if case .miniPlayer = oldValue {
                if newValue == .goLive || newValue == .progressBar {
                    globalNavState.isPiPMutiplayerView = false
                    globalNavState.isShowMutiplayerView = false
                }
            }
             */
        })
    
        .onExitCommand(perform: handleExitCommand)
        .ignoresSafeArea()
    }
    
    private func moveNext(_ direction: MoveCommandDirection) {
        if direction == .left {
            withAnimation(.easeInOut(duration: 0.3)) {
                globalNavState.isShowMutiplayerView = false
                focusedControl = .next
            }
        }
    }
    private func moveBottomButtons(_ direction: MoveCommandDirection) {
        if direction == .left {
            if isLiveContent {
                if focusedControl == .subtitles {
                    focusedControl = .playPause
                }
            }
        }
    }
    private func movePlayPause(_ direction: MoveCommandDirection) {
        if direction == .right || direction == .down {
            if isLiveContent {
                    focusedControl = .subtitles
            }
        }
    }
    private func moveNextKeyMoments(_ direction: MoveCommandDirection) {
        if direction == .right {
            if isLiveContent {
                if focusedControl == .next {
                    focusedControl = .miniPlayer(1)
                }
            }
        }
    }
    private func moveLivePlayer(_ direction: MoveCommandDirection) {
        if direction == .down || direction == .left {
            focusedControl = .progressBar
        }
    }
    
    // MARK: - CONTROL-BUTTON UI
    @ViewBuilder
    private func controlButton(
        title: String,
        icon: String,
        isFocused: Bool,
        completion: @escaping () -> Void
    ) -> some View {

        Button(action: completion) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 25, weight: isFocused ? .medium: .regular))
                    .foregroundColor(isFocused ? .green : .white)

                Text(title)
                    .font(.system(size: 25, weight:  isFocused ? .medium: .regular))
                    .foregroundColor(isFocused ? .green : .white)
            }
            .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
        .buttonStyle(.borderless)
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
    
    private var showBottomTabButtons: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [.black.opacity(0.8), .black.opacity(0.0)],
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 80)
            .ignoresSafeArea(edges: .bottom)
            
            // Your buttons centered inside gradient
            HStack(spacing: 40) {
                controlButton(title: "Subtitle & Audio", icon: "captions.bubble.fill", isFocused: focusedControl == .subtitles) { }
                    .focused($focusedControl, equals: .subtitles)
                    .onMoveCommand(perform: moveBottomButtons)
                
                controlButton(title: "Settings", icon: "gearshape.fill", isFocused: focusedControl == .settings) { }
                    .focused($focusedControl, equals: .settings)
                
                controlButton(title: "Key Moments", icon: "forward.end.fill", isFocused: focusedControl == .next) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        globalNavState.isShowMutiplayerView = true
                    }
                }
                .focused($focusedControl, equals: .next)
                .onMoveCommand(perform: moveNextKeyMoments)
                
                if globalNavState.isShowMutiplayerView {
                    VStack {
                        Rectangle()
                            .frame(width: 356, height: 80)
                            .background(Color.black)
                    }
                }
            }
        }
        //.frame(maxWidth: .infinity)
    }
    
    // Reusable item box
    @ViewBuilder
    func focusBox(for section: ControlFocus) -> some View {
        Color.clear
            .frame(width: 150, height: 150)
            .focusable(true)
            .focused($focusedControl, equals: section)
    }
}

// MARK: - Private Methods
private extension LivePlayerControlsView {
    
    func handleAppear() {
        print("*** LivePlayerControlsView handleAppear")
        print("*** ------------- END -----------------------")
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
           /* DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focusedControl = .go

            }*/
        }
        hideWorkItem = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: task)
    }
    
    func handleExitCommand() {
        destroyTapped()
        presentPlayPauseScreen = false
        globalNavState.activeScreen = nil
        
        print("**** onExitCommand LivePlayerControlsView")
    }
}
