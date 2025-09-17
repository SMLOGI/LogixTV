//
//  MasterVideoPlayer.swift
//  VideoPlayerSwiftUI
//
//  Created by Pradip on 14/05/25.
//

import UIKit
import AVKit

class MasterVideoPlayer: UIView {
    
    // MARK: - Setup AVPlayerLayer for this UIView
    override static var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    // Shortcut to get/set AVPlayer on this view's layer
    var player: AVPlayer! {
        get { (layer as? AVPlayerLayer)?.player }
        set { (layer as? AVPlayerLayer)?.player = newValue }
    }

    // Setup player and play
    func configureAndPlay(with url: URL, controller: VideoPlayerController? = nil) {
        
        // Setup audio session for playback (important for PiP and background audio)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        let avPlayer = AVPlayer(playerItem: item)
        self.player = avPlayer
        // Get the AVPlayerLayer from this view
        if let playerLayer = self.layer as? AVPlayerLayer {
            controller?.attach(to: avPlayer, playerLayer: playerLayer, playerView: self)
        }
        avPlayer.play()
    }
}
