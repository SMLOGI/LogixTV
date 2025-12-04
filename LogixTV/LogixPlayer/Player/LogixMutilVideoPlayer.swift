//
//  LogixMutilVideoPlayer.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 03/12/25.
//

import SwiftUI

struct LogixMultiVideoPlayer: View {
    
    var category: String
    
    @State var videoData: VideoData                // Full-screen video
    @State var videoDataList: [VideoData]          // Mini players on the right
    
    @Binding var isPresentingLogixPlayer: Bool
    
    @FocusState private var focusedIndex: Int?     // tvOS focus tracking
    
    let smallWidth: CGFloat = 400
    let smallHeight: CGFloat = 250
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            // --------------------------------------------------
            // MARK: FULL SCREEN MAIN PLAYER (not focusable)
            // --------------------------------------------------
            LogixVideoPlayer(
                category: category,
                videoData: videoData,
                isPresentingLogixPlayer: $isPresentingLogixPlayer,
                mute: .constant(false),
                showAds: .constant(true),
                onDismiss: { }
            )
            .focusable(false)
            .ignoresSafeArea()
            
            // --------------------------------------------------
            // MARK: MINI PLAYERS LIST
            // --------------------------------------------------
            HStack {
                Spacer()
                
                VStack(spacing: 50) {
                    ForEach(videoDataList.indices, id: \.self) { index in
                        miniPlayer(for: index)
                    }
                }
                .padding(.trailing, 40)
            }
        }
        .background(Color.black)
        .onAppear {
            focusedIndex = 0    // Default focus to the first mini player
        }
    }
    
    
    // --------------------------------------------------
    // MARK: MINI PLAYER VIEW
    // --------------------------------------------------
    @ViewBuilder
    private func miniPlayer(for index: Int) -> some View {
        
        let isFocused = (focusedIndex == index)
        
        LogixVideoPlayer(
            category: category,
            videoData: videoDataList[index],
            isPresentingLogixPlayer: $isPresentingLogixPlayer,
            mute: .constant(true),
            showAds: .constant(false),
            onDismiss: { }
        )
        .frame(width: smallWidth, height: smallHeight)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        
        // White border when focused
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? Color.white : Color.clear, lineWidth: 6)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        )
        
        .focusable(true)
        .focused($focusedIndex, equals: index)
        .onTapGesture {
            swapToFullScreen(index)
        }
    }
    
    
    // --------------------------------------------------
    // MARK: SWAP MAIN ↔ MINI PLAYER
    // --------------------------------------------------
    private func swapToFullScreen(_ index: Int) {
        withAnimation(.easeInOut(duration: 0.35)) {
            
            let tapped = videoDataList[index]
            videoDataList[index] = videoData
            videoData = tapped
            
            // Keep focus on the same mini player index after swap
            focusedIndex = index
        }
    }
}

