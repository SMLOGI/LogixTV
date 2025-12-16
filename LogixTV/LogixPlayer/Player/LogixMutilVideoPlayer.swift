//
//  LogixMutilVideoPlayer.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 03/12/25.
//

import SwiftUI

struct LogixMutilVideoPlayer: View {
    
    var category: String
    var triggerType: PlayerTriggerType
    @Binding var videoData: CarouselContent?
    @Binding var miniplayerConetnt: MiniPlayerContent?
    
    @Binding var isPresentingLogixPlayer: Bool
    @FocusState.Binding var focusedField: FocusTarget?
    
    @EnvironmentObject var globalNavState: GlobalNavigationState
    // @EnvironmentObject var mpManager: MultiPlayerManager
    @StateObject private var mainPlaybackViewModel = PlaybackViewModel()
    @StateObject private var miniPlaybackViewModel = PlaybackViewModel()
    
    let mainPlayerController = PlayerContainerViewController()
    let miniPlayerController = PlayerContainerViewController()
    
    let smallWidth: CGFloat = 300
    let smallHeight: CGFloat = 250
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            if videoData?.isLiveContent == false {
                if let videoData, let video = makeVideoData(from: videoData) {
                    LogixVideoPlayer(category: category, videoData: video, isPresentingLogixPlayer: $isPresentingLogixPlayer, mute: .constant(false), showAds: .constant(true), playbackViewModel: mainPlaybackViewModel, isMainLivePlayer: .constant(true), onDismiss: {
                        print("*** LogixMutilVideoPlayer non live content")
                    })
                        .focusable(false)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
                
            } else {
                if globalNavState.isPiPMutiplayerView {
                    // Mini Player
                    HStack(spacing: 0.0) {
                        if let miniContent = globalNavState.miniPlayerItem, let video = makeVideoData(from: miniContent) {
                            LogixVideoPlayer(category: category, videoData: video, isPresentingLogixPlayer: $isPresentingLogixPlayer, mute: .constant(false), showAds: .constant(false), playbackViewModel: miniPlaybackViewModel, isMainLivePlayer: .constant(false), onDismiss: {
                                print("*** LogixMutilVideoPlayer live mini content")
                            })
                            .id(globalNavState.miniPlayerItem?.id)
                            .focusable(false)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        }
                        if globalNavState.isShowMutiplayerView {
                            Spacer()
                                .frame(width: 356, height: 100)
                                .padding(.vertical, 20)
                                .background(Color.black)
                                .focusSection()
                        }
                    }
                }
                // Main Player
                HStack(alignment: .top, spacing: 0.0) {
                    if globalNavState.isPiPMutiplayerView {
                        Spacer()
                    }
                    VStack(alignment: .trailing) {
                        if globalNavState.isPiPMutiplayerView {
                            Spacer()
                        }
                        if let videoData, let video = makeVideoData(from: videoData) {
                            LogixVideoPlayer(category: category, videoData: video, isPresentingLogixPlayer: $isPresentingLogixPlayer, mute: .constant(false), showAds: .constant(false), playbackViewModel: mainPlaybackViewModel, isMainLivePlayer: .constant(true), onDismiss: {
                                print("*** LogixMutilVideoPlayer live main content")
                            })
                                .focusable(false)
                                .frame(
                                    width: globalNavState.isPiPMutiplayerView ? 400 : nil,
                                    height: globalNavState.isPiPMutiplayerView ? 220 : nil
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(globalNavState.isPiPMutiplayerView ? (globalNavState.isGoLiveFocused ? .green : .white) : .clear, lineWidth: globalNavState.isGoLiveFocused ? 4 :( globalNavState.isPiPMutiplayerView ? 2 : 0))
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                                .padding(.bottom, globalNavState.isPiPMutiplayerView ? 60: 0)
                                .padding(.trailing, globalNavState.isPiPMutiplayerView ? 10: 0)
                                .animation(.easeInOut(duration: 0.35), value: globalNavState.isPiPMutiplayerView)
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .background(Color.clear)
                    
                    if globalNavState.isShowMutiplayerView {
                        Spacer()
                            .frame(width: 356)
                            .padding(.vertical, 20)
                            .background(Color.black)
                            .focusSection()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .onAppear {
            print("*** LogixMutilVideoPlayer onAppear")
            mainPlaybackViewModel.destroyPlayer()
           // miniPlaybackViewModel.destroyPlayer()
            globalNavState.isShowMutiplayerView = false
            globalNavState.isPiPMutiplayerView = false
        }
    }
    func makeVideoData(from item: CarouselContent) -> VideoData? {
        guard let urlString = item.video?.first?.contentUrl, let _ = URL(string: urlString) else { return nil }
        return VideoData( type: "vod", title: item.title ?? "", profile: "pradip", drmEnabled: false, licenceUrl: item.bestImageURL?.absoluteString ?? "", contentUrl: urlString, protocol: "", encryptionType: "hls", adInfo: nil, qualityGroup: .none, isLiveContent: item.isLiveContent)
    }
    func makeVideoData(from item: MiniPlayerContent) -> VideoData? {
        guard let _ = URL(string: item.contentUrl) else { return nil }
        return VideoData( type: "vod", title: item.title, profile: "pradip", drmEnabled: false, licenceUrl: item.imageUrl, contentUrl: item.contentUrl, protocol: "", encryptionType: "hls", adInfo: nil, qualityGroup: .none, isLiveContent: true)
    }
}
