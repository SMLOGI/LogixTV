//
//  SearchView.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 16/09/25.
//

import Foundation
import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @FocusState.Binding var focusedField: FocusTarget?
    @State private var isPresentingLogixPlayer = false
    @EnvironmentObject var globalNavigationState: GlobalNavigationState
    let columns = [GridItem(.adaptive(minimum: 267), spacing: 30)]
    @StateObject private var mainPlaybackViewModel = PlaybackViewModel()
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()


            ScrollView {
                LazyVGrid(columns: columns, spacing: 30) {
                    ForEach(viewModel.filteredItems, id: \.id) { item in
                        CarouselCardButtonView(item: item, group: nil, focusedItem: $focusedField) {
                            globalNavigationState.contentItem = item
                            isPresentingLogixPlayer = true
                        }
                    }
                }
                .padding()
            }
            .fullScreenCover(isPresented: $isPresentingLogixPlayer) {
                showPlayerView()
            }
            .searchable(text: $viewModel.searchText)
        }
    }

    @ViewBuilder
    private func showPlayerView() -> some View {
        ZStack {
            Color.gray.ignoresSafeArea()

            if let contentItem = globalNavigationState.contentItem,
               let videoUrlString = contentItem.video?.first?.contentUrl,
               let videoUrl = URL(string: videoUrlString) {

                let videoData = VideoData(
                    type: "vod",
                    profile: "pradip",
                    drmEnabled: false,
                    licenceUrl: "",
                    contentUrl: videoUrl.absoluteString,
                    protocol: "",
                    encryptionType: "hls",
                    adInfo: nil,
                    qualityGroup: .none
                )

                LogixVideoPlayer(
                    category: "ccategory",
                    videoData: videoData,
                    isPresentingLogixPlayer: $isPresentingLogixPlayer,
                    mute: .constant(false),
                    showAds: .constant(true),
                    playbackViewModel: mainPlaybackViewModel,
                    isMainLivePlayer: .constant(true),
                    onDismiss: { }
                )
            }
        }
    }
}
