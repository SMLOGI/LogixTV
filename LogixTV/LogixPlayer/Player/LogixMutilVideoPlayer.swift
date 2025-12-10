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
    
    let smallWidth: CGFloat = 300
    let smallHeight: CGFloat = 250
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            
           // Mini Player
            HStack(spacing: 0.0) {
                if let miniContent = miniplayerConetnt, let video = makeVideoData(from: miniContent) {
                    LogixVideoPlayer(category: category, videoData: video, isPresentingLogixPlayer: $isPresentingLogixPlayer, mute: .constant(false), showAds: .constant(false), onDismiss: { }) .focusable(false)
                        .focusSection()
                }
                if globalNavState.isShowMutiplayerView {
                    Rectangle()
                        .frame(width: 356)
                        .padding(.vertical, 20)
                        .background(Color.black)
                        .focusSection()
                }
            }
            // Main Player
            HStack(alignment: .top, spacing: 0.0) {
                if globalNavState.isPiPMutiplayerView {
                    Spacer()
                }
                VStack(alignment: .trailing) {
                    if let videoData, let video = makeVideoData(from: videoData) {
                        LogixVideoPlayer(category: category, videoData: video, isPresentingLogixPlayer: $isPresentingLogixPlayer, mute: .constant(false), showAds: .constant(false), onDismiss: { }) .focusable(false)
                            .frame(
                                width: globalNavState.isPiPMutiplayerView ? 400 : nil,
                                height: globalNavState.isPiPMutiplayerView ? 250 : nil
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        
                    }
                    if globalNavState.isPiPMutiplayerView {
                        Spacer()
                    }

                }
                .frame(maxHeight: .infinity)
                .background(Color.green)
                
                if globalNavState.isShowMutiplayerView {
                    Rectangle()
                        .frame(width: 356)
                        .padding(.vertical, 20)
                        .background(Color.black)
                        .focusSection()
                }
                
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    func makeVideoData(from item: CarouselContent) -> VideoData? {
        guard let urlString = item.video?.first?.contentUrl, let _ = URL(string: urlString) else { return nil }
        return VideoData( type: "vod", profile: "pradip", drmEnabled: false, licenceUrl: "", contentUrl: urlString, protocol: "", encryptionType: "hls", adInfo: nil, qualityGroup: .none)
    }
    func makeVideoData(from item: MiniPlayerContent) -> VideoData? {
        guard let _ = URL(string: item.contentUrl) else { return nil }
        return VideoData( type: "vod", profile: "pradip", drmEnabled: false, licenceUrl: "", contentUrl: item.contentUrl, protocol: "", encryptionType: "hls", adInfo: nil, qualityGroup: .none)
    }
}
