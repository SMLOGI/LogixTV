//
//  SwiftUIVideoPlayer.swift
//  VideoPlayerSwiftUI
//
//  Created by Pradip on 14/05/25.
//

import SwiftUI

struct SwiftUIVideoPlayer: UIViewRepresentable {
    let videoURL: URL
    let controller: VideoPlayerController?

    func makeUIView(context: Context) -> MasterVideoPlayer {
        let view = MasterVideoPlayer()
        view.configureAndPlay(with: videoURL,controller: controller)
        return view
    }
    func updateUIView(_ uiView: MasterVideoPlayer, context: Context) {
        
    }
}

#Preview {
    SwiftUIVideoPlayer(videoURL: URL(string: "")!, controller: VideoPlayerController())
}
