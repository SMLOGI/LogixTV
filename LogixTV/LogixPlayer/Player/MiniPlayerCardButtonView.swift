//
//  MiniPlayerCardButtonView.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 05/12/25.
//

import SwiftUI

struct MiniPlayerCardButtonView: View, Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.item.id == rhs.item.id &&
        lhs.focusedControl == rhs.focusedControl
    }
    
    let item: MiniPlayerContent
    @FocusState.Binding var focusedControl: LivePlayerControlsView.ControlFocus?
    @State private var showDetails = false
    @EnvironmentObject var globalNavState: GlobalNavigationState
    var completion: (() -> Void)?
    
    var isCurrentlyPlaying: Bool {
        globalNavState.miniPlayerItem?.id == item.id
    }
    
    var body: some View {
        HStack {
            Button(action: { completion?() }) {
                ZStack(alignment: .topTrailing) {
                    // Thumbnail image
                    VStack {
                        if let imageUrl = URL(string: item.imageUrl) {
                            CachedAsyncImage(url: imageUrl)
                                .aspectRatio(16/9, contentMode: .fill)
                        } else {
                            Rectangle()
                                .fill(Color.gray)
                        }
                    }
                    .frame(width: 356, height: 200)
                    .cornerRadius(12)
                    
                    // ⭐ NOW PLAYING overlay
                    if isCurrentlyPlaying {
                        NowPlayingPill()
                            .padding(10)
                    }
                    
                    // 🔹 Bottom-center "Key Moments"
                    Text("Key Moments: \(item.id)")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 2)
                        .font(.caption2)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.black.opacity(0.25))
                        )
                        .padding(.top, 160) // distance from bottom
                        .padding(.trailing, 70)
                    
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white, lineWidth: focusedControl == .miniPlayer(item.id) ? 10 : 0)
                )
            }
            .focused($focusedControl, equals: .miniPlayer(item.id))
            .buttonStyle(.card)
        }
    }
}

struct NowPlayingPill: View {
    @State private var scale: CGFloat = 1

    var body: some View {
        HStack {
            Text("NOW PLAYING")
                .font(.system(size: 20))
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.red)
        .cornerRadius(5)
        .onAppear { scale = 1.6 }
    }
}
