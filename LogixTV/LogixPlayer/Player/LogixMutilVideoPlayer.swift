//
//  LogixMutilVideoPlayer.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 03/12/25.
//

import SwiftUI

struct LogixMultiVideoPlayer: View {
    
    var category: String
    @State var videoData: CarouselContent                // Full-screen video
    @State var videoDataList: [CarouselContent]          // Mini players on the right
    
    @Binding var isPresentingLogixPlayer: Bool
    @FocusState.Binding var focusedField: FocusTarget?
    @EnvironmentObject var globalNavState: GlobalNavigationState
    
    
    let smallWidth: CGFloat = 300
    let smallHeight: CGFloat = 250
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            // --------------------------------------------------
            // MARK: MINI PLAYERS LIST
            // --------------------------------------------------
            HStack(spacing: 0.0) {
                
                if let video = makeVideoData(from: videoData) {
                    LogixVideoPlayer(
                        category: category,
                        videoData: video,
                        isPresentingLogixPlayer: $isPresentingLogixPlayer,
                        mute: .constant(false),
                        showAds: .constant(true),
                        onDismiss: { }
                    )
                    .focusable(false)
                }
                if globalNavState.isShowMutiplayerView {
                    VStack(alignment: .center) {
                            ForEach(videoDataList, id: \.id) { item in
                                MiniPlayerCardButtonView(item: item, focusedItem: $focusedField) {
                                    globalNavState.contentItem = item
                                    isPresentingLogixPlayer = true
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                    }
                    .frame(width: 356)
                    .padding(.vertical, 20)
                    .background(Color.black)
                }
            }
        }
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




